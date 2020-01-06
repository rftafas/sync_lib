----------------------------------------------------------------------------------
-- Sync_lib  by Ricardo F Tafas Jr
-- This is an ancient library I've been using since my earlier FPGA days.
-- Code is provided AS IS.
-- Submit any suggestions to GITHUB ticket system.
----------------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
library stdblocks;
    use stdblocks.sync_lib.all;


entity pulse_align is
    generic (
      port_size : integer := 8
    );
    port (
      rst_i  : in  std_logic;
      mclk_i : in  std_logic;
      en_i   : in  std_logic_vector(port_size-1 downto 0);
      en_o   : out std_logic_vector(port_size-1 downto 0)
    );
end pulse_align;

architecture behavioral of pulse_align is

  --for the future: include attributes for false path.
  type align_t is (idle, wait_others, active);
  type fsm_vector_t is array (en_i'range) of align_t;
  signal mq_align : fsm_vector_t;

  function next_state_logic (
    enable        : std_logic;
    status        : std_logic_vector(en_i'range);
    current_state : align_t
    ) return align_t is

      variable tmp : align_t;
  begin
    tmp := current_state;
    case current_state is
        when idle        =>
          if enable = '1' then
            tmp :=  wait_others;
          end if;

        when wait_others =>
          if status = (status'range => '1') then
            tmp :=  active;
          end if;

        when others      =>
          tmp := idle;

      end case;
      return tmp;
  end function;

  function decode_status( current_state : align_t ) return std_logic is
    begin
      case current_state is
        when wait_others =>
          return '1';

        when others      =>
          return '0';

      end case;
  end function;

  function decode_out( current_state : align_t ) return std_logic is
    begin
      case current_state is
        when active =>
          return '1';

        when others =>
          return '0';

      end case;
  end function;

begin

  process(mclk_i, rst_i)
    variable status_v : std_logic_vector(en_i'range) := (others=>'0');
  begin
    if rst_i = '1' then
      mq_align <= (others=>idle);
    elsif rising_edge(mclk_i) then
      for j in en_i'range loop
        status_v(j) := decode_status(mq_align(j));
      end loop;
      for j in en_i'range loop
        mq_align(j) <= next_state_logic(en_i(j), status_v, mq_align(j));
      end loop;
    end if;
  end process;

  out_gen : for j in en_i'range generate
    en_o(j)        <= decode_out(mq_align(j));
  end generate;

end behavioral;

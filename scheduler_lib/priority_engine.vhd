----------------------------------------------------------------------------------
-- Priority Engine for granting resources to those requesting it.
-- Usage: choose one of the priority types.
-- Raise the request input to request a resource. wait for grant.
-- when done using, ack it.
-- This block does not prevent bad behavior. that can be made outside with
-- nice counters.
--
-- if you are asking why natural, try asking the guys from vivadosim.
----------------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity priority_engine is
    generic (
      n_elements : integer := 8;
      mode       : integer := 0
    );
    port (
      --general
      clk_i       : in  std_logic;
      rst_i       : in  std_logic;
      --python script port creation starts
      request_i    : in  std_logic_vector(n_elements-1 downto 0);
      ack_i        : in  std_logic_vector(n_elements-1 downto 0);
      grant_o      : out std_logic_vector(n_elements-1 downto 0);
      index_o      : out natural
    );
end priority_engine;

architecture behavioral of priority_engine is

  function integer_count ( input : integer; limit : integer; up_cnt : boolean) return integer is
    variable tmp : integer;
  begin
    if up_cnt then
      if input = limit then
        tmp := 0;
      else
        tmp := input+1;
      end if;
    else
      if input = 0 then
        tmp := limit-1;
      else
        tmp := input-1;
      end if;
    end if;
    return tmp;
  end integer_count;

  type index_sr_t is array (n_elements-1 downto 0) of integer;
  signal index_sr         : index_sr_t := (others=>0);
  signal moving_index_s   : natural := 0;
  signal priority_index_s : natural := 0;

begin



  mode_gen: case mode generate

    when 1 =>

    when 2 =>

    when 3 =>

    when others =>


    end generate;


end behavioral;

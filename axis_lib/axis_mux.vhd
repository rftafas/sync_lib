----------------------------------------------------------------------------------
-- This block was autogenerated with axis.py
-- If you want to change number of ports, use:
-- python axis.py create concat 'entity name' '# of ports'
----------------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity axis_mux is
    generic (
      tdata_size   : integer := 8;
      tdest_size   : integer := 8;
      tuser_size   : integer := 8;
      select_auto  : boolean := false;
      switch_tlast : boolean := false;
      interleaving : boolean := false;
      max_tx_size  : integer := 10;
      mode         : integer := 10
    );
    port (
      --general
      clk_i       : in  std_logic;
      rst_i       : in  std_logic;
      --python port code
      --AXIS Master port
      m_tdata_o    : out std_logic_vector(tdata_size-1 downto 0);
      m_tuser_o    : out std_logic_vector(tuser_size-1 downto 0);
      m_tdest_o    : out std_logic_vector(tdest_size-1 downto 0);
      m_tready_i   : in  std_logic;
      m_tvalid_o   : out std_logic;
      m_tlast_o    : out std_logic
    );
end axis_mux;

architecture behavioral of axis_mux is

  --python constant code

  component priority_engine is
    generic (
      n_elements : integer := 8;
      mode       : integer := 0
    );
    port (
      clk_i     : in  std_logic;
      rst_i     : in  std_logic;
      request_i : in  std_logic_vector(n_elements-1 downto 0);
      ack_i     : in  std_logic_vector(n_elements-1 downto 0);
      grant_o   : out std_logic_vector(n_elements-1 downto 0);
      index_o   : out integer
    );
  end component;

  signal tx_count_s : integer;
  signal index_s    : integer range 0 to number_ports-1 := 0;
  signal ack_s      : std_logic_vector(number_ports-1 downto 0);

  type axi_tdata_array is array (number_ports-1 downto 0) of std_logic_vector(tdata_size-1 downto 0);
  type axi_tuser_array is array (number_ports-1 downto 0) of std_logic_vector(tuser_size-1 downto 0);
  type axi_tdest_array is array (number_ports-1 downto 0) of std_logic_vector(tdest_size-1 downto 0);

  signal axi_tdata_s : axi_tdata_array;
  signal axi_tuser_s : axi_tuser_array;
  signal axi_tdest_s : axi_tdest_array;

  signal s_tvalid_s : std_logic_vector(number_ports-1 downto 0);
  signal  s_tlast_s : std_logic_vector(number_ports-1 downto 0);
  signal s_tready_s : std_logic_vector(number_ports-1 downto 0);

begin

  --slave connections
  --array connections

  --output selection
  m_tdata_o  <= axi_tdata_s(index_s);
  m_tdest_o  <= axi_tdest_s(index_s);
  m_tuser_o  <= axi_tuser_s(index_s);
  m_tvalid_o <= s_tvalid_s(index_s);
  m_tlast_o  <= s_tlast_s(index_s);

  process(all)
  begin
    if rst_i = '1' then
      tx_count_s <= 0;
    elsif rising_edge(clk_i) then
      --max size count
      if max_tx_size = 0 then
        tx_count_s <= 1;
      elsif (s_tready_s(index_s) and s_tvalid_s(index_s)) = '1' then
        if ack_s(index_s) = '1' then
          tx_count_s <= 0;
        elsif tx_count_s = max_tx_size-1 then
          tx_count_s <= 0;
        else
          tx_count_s <= tx_count_s + 1;
        end if;
      end if;
    end if;
  end process;

--ready connections

  priority_engine_i : priority_engine
    generic map (
      n_elements => number_ports,
      mode       => mode
    )
    port map (
      clk_i     => clk_i,
      rst_i     => rst_i,
      request_i => s_tvalid_s,
      ack_i     => ack_s,
      grant_o   => s_tready_s,
      index_o   => index_s
    );

    ack_gen : for j in number_ports-1 downto 0 generate
      ack_s(j) <= s_tlast_s(j) when switch_tlast               else
                  '1'          when tx_count_s = max_tx_size-1 else
                  '1'          when interleaving               else
                  '0';
    end generate;

end behavioral;

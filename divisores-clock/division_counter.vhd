--! Primeiro contador feito. 
-- Funciona, só mudei o nome pra usar só nos divisores

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity division_counter is
    port(
        clock, clear, load, enable : in std_logic;
        decade : in std_logic;
        l : in std_logic_vector(3 downto 0);
        q : out std_logic_vector(3 downto 0);
        rco : out std_logic
    );
end division_counter;

architecture counter of division_counter is
    signal qi : std_logic_vector(3 downto 0);

begin
    process(clock, clear)
    begin
		if clear='1' or (decade='1' and qi="1010") then   -- Clear assincrono
			qi <= "0000";
		elsif (load='1' and rising_edge(clock)) then      -- Load ativo alto
			qi <= l;
		elsif (enable='1' and rising_edge(clock)) then
			qi <= qi + "0001";
		end if;
		
		if qi="1111" or (decade='1' and qi="1001") then                                  -- rco no valor max
			rco <= '1';
		else
			rco <= '0';
		end if;
    --q <= qi;
	end process;
	 q <= qi;
	
end counter;

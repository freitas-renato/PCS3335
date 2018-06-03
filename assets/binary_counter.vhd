library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- Contador binario ou decimal, crescente ou decrescente
entity binary_counter is
	port(
        clock:   in std_logic;
        clear:   in std_logic; -- Clear assíncrono
        load:    in std_logic;
        enable:  in std_logic;
        sentido: in std_logic; -- 0-crescente, 1-decrescente
        decade:  in std_logic; -- 0-binario, 1-dédaca
        l:       in std_logic_vector(3 downto 0); -- Valor do load
        
        -- Saidas
        q:       out std_logic_vector(3 downto 0);
        rco:     out std_logic
	);
end binary_counter;

architecture counter of binary_counter is
    signal qi : std_logic_vector(3 downto 0);

begin
    process(clock, clear)
    begin
        -- Clear assincrono sentido crescente
        if ((clear='1' or (decade='1' and qi="1010")) and sentido = '0') then
            qi <= "0000";
        -- Clear sentido decrescente
        elsif clear = '1' and sentido = '1' then 
            if decade = '1' then 
                qi <= "1001";
            else
                qi <= "1111";
            end if;
        -- Load sincrono
        elsif (load='1' and rising_edge(clock)) then 
            qi <= l;
        elsif (enable='1' and rising_edge(clock)) then
            if sentido = '0' then
                qi <= qi + "0001";
            else
                qi <= qi - "0001";
            end if;
        end if;

        if decade = '1' and qi >= "1010" then
            qi <= "1001";
        end if;
        
        -- seg <= qi;
        rco <= '0';

        -- RCO sentido crescente
        if ((qi="1111" or (decade='1' and qi="1001")) and sentido = '0' and enable = '1') then
            rco <= '1';
        -- RCO sentido decrescente
        elsif qi = "0000" and sentido = '1' and enable = '1' then 
            rco <= '1';
        end if;
        --q <= qi;
    end process;
    q <= qi;

end counter;

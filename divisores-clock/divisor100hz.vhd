library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity divisor100hz is
    port(
        clk : in std_logic;
        clk_out : out std_logic
    );
end divisor100hz;

architecture comportamental of divisor100hz is
    component division_counter is
        port(
            clock, clear, load, enable : in std_logic;
			--sentido: in std_logic;
            -- 1 se for contador de decada	
            decade : in std_logic;
            -- Carga load
            l : in std_logic_vector(3 downto 0);
            -- Saida
            q : out std_logic_vector(3 downto 0);
            rco : out std_logic
        );
    end component;

    signal qi1, qi2, qi3, qi4, qi5, qi6, qi7, d1 : std_logic_vector(3 downto 0);
    signal en_1, en_2, en_3, en_4, en_5, en_6, en_7, en_d : std_logic:='0';
    signal rco_1, rco_2, rco_3, rco_4, rco_5, rco_6, rco_7 : std_logic:='0';
    signal rst_b, rst_d : std_logic:='0';

    
begin
    -- Contadores cascateados para a divisao
    b1: division_counter port map(clk, rst_b, '0', en_1, '0', "0000", qi1, rco_1);
    b2: division_counter port map(clk, rst_b, '0', en_2, '0', "0000", qi2, rco_2);
    b3: division_counter port map(clk, rst_b, '0', en_3, '0', "0000", qi3, rco_3);
    b4: division_counter port map(clk, rst_b, '0', en_4, '0', "0000", qi4, rco_4);
    b5: division_counter port map(clk, rst_b, '0', en_5, '0', "0000", qi5, rco_5);
    b6: division_counter port map(clk, rst_b, '0', en_6, '0', "0000", qi6, rco_6);
    b7: division_counter port map(clk, rst_b, '0', en_7, '0', "0000", qi7, rco_7);
    
    -- Clock resultante é a saída LSB desse contador
    decade: division_counter port map(clk, rst_d, '0', en_d, '1', "0000", d1, open);
	 
	 
    -- Enables para contagem 
    en_1 <= '1';
    en_2 <= rco_1;
    en_3 <= rco_2 and en_2;
    en_4 <= rco_3 and en_3;
    en_5 <= rco_4 and en_4; 
    en_6 <= rco_5 and en_5; 
    en_7 <= rco_6 and en_6;
    
    -- Contador de decada só conta quando a contagem chegar a 50000
    en_d <= '1' when (qi1="0000" and qi2="0010" and qi3="0001" and qi4="1010" and qi5="0111" and qi6="0000" and qi7="0000") else '0';
    -- Reset dos binarios apos o sinal de subida acima
    rst_b <= '1' when (qi1="0000" and qi2="0010" and qi3="0001" and qi4="1010" and qi5="0111" and qi6="0000" and qi7="0000") else '0';


    -- Clock dividido: LSB do ultimo contador
    clk_out <= d1(0);


    

end architecture;

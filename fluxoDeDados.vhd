-- fluxoDeDados.vhd
--  Instanicia os dois jogadores
--  Usa sinais da unidade de controle pra decidir a saída
--  Saída já vai convertida pra 7 segmentos

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fluxoDeDados is
    port(
        --clock_in: in std_logic -- Clock no botao pra debug
        clock_out: out std_logic; -- Clock out pra debug
        
        clock:    in std_logic; -- Clock 50 MHz
        enable:   in std_logic;
        clear:    in std_logic;
        -- reset:    in std_logic;
        preset:   in std_logic; -- 1 = carrega o valor
        seletor:  in std_logic; -- Seletor de jogador ativo
        modo:     in std_logic; -- Modo de visualização: 1 ou 2 jogadores
        fischer:  in std_logic; -- Load Fishcer
        bron:     in std_logic; -- Load Bronstein

        delta1:   in std_logic_vector(3 downto 0); -- Dígito 1 do delta
        delta2:   in std_logic_vector(3 downto 0); -- Dígito 2 do delta

        preset1:  in std_logic_vector(3 downto 0); -- Dígito 1 do preset (minutos)
        preset2:  in std_logic_vector(3 downto 0); -- Dígito 2 do preset (minutos)
          
        
        -- Saida para os displays 7 segmentos
        d1_7, d2_7, d3_7, d4_7, d5_7, d6_7: out std_logic_vector(6 downto 0);
        
        fim: out std_logic -- Quando um dos jogadores chega a 00:00
    );

end fluxoDeDados;

architecture comportamental of fluxoDeDados is
    -- component binary_counter is
    --     port(
    --         clock:   in std_logic;
    --         clear:   in std_logic; -- Clear assíncrono
    --         load:    in std_logic;
    --         enable:  in std_logic;
    --         sentido: in std_logic; -- 0-crescente, 1-decrescente
    --         decade:  in std_logic; -- 0-binario, 1-dédaca
    --         l:       in std_logic_vector(3 downto 0); -- Valor do load
        
    --         -- Saidas
    --         q:       out std_logic_vector(3 downto 0);
    --         rco:     out std_logic
    --     );
    -- end component;

    -- component divisor is
    --     port(
    --         clk: in std_logic;
    --         c_1, c_100, c_1k: out std_logic
    --     );
    -- end component;

    -- component somadorBCD is
    --     port(
    --         abcd:    in  std_logic_vector (3 downto 0);
    --         bbcd:    in  std_logic_vector (3 downto 0);
    --         cinbcd:  in  std_logic;
    --         coutbcd: out  std_logic;
    --         s:       out  std_logic_vector (3 downto 0)
    --     );
    -- end component;

    component divisor100hz is
        port(
            clk: in std_logic;
            clk_out: out std_logic
        );
    end component;

    component setesegmentos is
        port(
            entrada: in std_logic_vector(3 downto 0);
            saida:  out std_logic_vector(6 downto 0)
        );
    end component;


    component jogador is
        port(
            clock:    in std_logic; -- Clock 50 MHz
            enable:   in std_logic; -- Seleciona o jogador
            clear:    in std_logic;
            preset:   in std_logic; -- Valor inicial
            fischer:  in std_logic; -- Seleção load Fishcer
            bron:     in std_logic; -- Seleção load Bronstein
            
            delta1:   in std_logic_vector(3 downto 0); -- Dígito 1 do delta
            delta2:   in std_logic_vector(3 downto 0); -- Dígito 2 do delta
            
            preset1:  in std_logic_vector(3 downto 0); -- Dígito 1 do preset (minutos)
            preset2:  in std_logic_vector(3 downto 0); -- Dígito 2 do preset (minutos)
    
            -- Saidas da contagem
            q1, q2, q3, q4, q5, q6: out std_logic_vector(3 downto 0)
        );
    end component;

    signal clock_1hz, clock_100hz, clock_1khz: std_logic;
    
    -- Sinais para o jogador 1
    signal q1_1, q1_2, q1_3, q1_4, q1_5, q1_6: std_logic_vector(3 downto 0); -- Contadores 
    signal enableJ1: std_logic := enable and seletor; -- seletor vem da UC

    -- Sinais para o jogador 2
    signal q2_1, q2_2, q2_3, q2_4, q2_5, q2_6: std_logic_vector(3 downto 0); -- Contadores
    signal enableJ2: std_logic := enable and not(seletor); -- seletor vem da UC

    signal d1, d2, d3, d4, d5, d6: std_logic_vector(3 downto 0);

    
begin
    -- Divisor de clock com saidas de 1hz e 100hz
    -- div: divisor port map(clock, clock_1hz, clock_100hz, clock_1khz);
    div100: divisor100hz port map(clock, clock_100hz);
    -- div1:   divisor1hz   port map(clock, clock_1hz);
    
    JOGADOR1: jogador port map(
        clock   => clock_100hz,
        enable  => enableJ1,
        clear   => clear,
        preset  => preset,
        fischer => fischer,
        bron    => bron,
        delta1  => delta1,
        delta2  => delta2,
        preset1 => preset1,
        preset2 => preset2,

        q1=>q1_1, q2=>q1_2, q3=>q1_3, q4=>q1_4, q5=>q1_5, q6=>q1_6
    );

    JOGADOR2: jogador port map(
        clock   => clock_100hz,
        enable  => enableJ2,
        clear   => clear,
        preset  => preset,
        fischer => fischer,
        bron    => bron,
        delta1  => delta1,
        delta2  => delta2,
        preset1 => preset1,
        preset2 => preset2,

        q1=>q2_1, q2=>q2_2, q3=>q2_3, q4=>q2_4, q5=>q2_5, q6=>q2_6
    );
                
    
    d1 <=   q1_1   when (modo = '1' and enableJ1 = '1') else
            q2_1   when (modo = '1' and enableJ2 = '1') else
            q2_5   when (modo = '0') else
            "1111";
    
    d2 <=   q1_2   when (modo = '1' and enableJ1 = '1') else
            q2_2   when (modo = '1' and enableJ2 = '1') else
            q2_6   when (modo = '0') else
            "1111";
    
    d3 <=   q1_3   when (modo = '1' and enableJ1 = '1') else
            q2_3   when (modo = '1' and enableJ2 = '1') else
            "1111";
    
    d4 <=   q1_4   when (modo = '1' and enableJ1 = '1') else
            q2_4   when (modo = '1' and enableJ2 = '1') else
            "1111";
    
    d5 <=   q1_5   when (modo = '1' and enableJ1 = '1') else
            q2_5   when (modo = '1' and enableJ2 = '1') else
            q1_5   when (modo = '0') else
            "1111";
    
    d6 <=   q1_6   when (modo = '1' and enableJ1 = '1') else
            q2_6   when (modo = '1' and enableJ2 = '1') else
            q1_6   when (modo = '0') else
            "1111";
    
    disp1: setesegmentos port map(d1, d1_7);
    disp2: setesegmentos port map(d2, d2_7);
    disp3: setesegmentos port map(d3, d3_7);
    disp4: setesegmentos port map(d4, d4_7);
    disp5: setesegmentos port map(d5, d5_7);
    disp6: setesegmentos port map(d6, d6_7);

    fim <= '1' when (
            (q1_1 = "0000" and q1_2 = "0000" and q1_3 = "0000" and q1_4 = "0000" and q1_5 = "0000" and q1_6 = "0000") or
            (q2_1 = "0000" and q2_2 = "0000" and q2_3 = "0000" and q2_4 = "0000" and q2_5 = "0000" and q2_6 = "0000")
        ) else
        '0';

	clock_out <= clock_100hz; -- Debug
end architecture;

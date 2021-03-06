-- jogador.vhd
--  Instancia um jogador com 6 contadores (MM:SS:CC)
--  Contador mais significativo: dezena de minuto
--  Clock precisa ser de 100Hz para contagem de tempo correta

-- @TODO: - mudar o contador de segundos pra começar no 60 (começa em 99)
--        - implementar método de Bronstein (É MUITO CHATO AAAAAAA)
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity jogador is
    port(
        clock:    in std_logic; -- Clock de entrada
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
end jogador;

architecture comportamental of jogador is
    component binary_counter is
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
    end component;

    component somadorBCD is
        port(
            abcd:    in  std_logic_vector (3 downto 0);
            bbcd:    in  std_logic_vector (3 downto 0);
            cinbcd:  in  std_logic;
            coutbcd: out std_logic;
            s:       out std_logic_vector (3 downto 0)
        );
    end component;

    signal qi1, qi2, qi3, qi4, qi5, qi6: std_logic_vector (3 downto 0);   -- Saidas contadores
    signal rco1, rco2, rco3, rco4, rco5, rco6: std_logic;                 -- RCOs dos contadores
    signal load1, load2, load3, load4, load5, load6: std_logic_vector(3 downto 0); -- Load p cada contador
    
    -- Sinais auxiliares Fischer
    signal cout1, cout2, cout3: std_logic;
    signal lfischer_1, lfischer_2, lfischer_3, lfischer_4: std_logic_vector(3 downto 0);

    -- Sinais auxiliares Bronstein
    signal bron1, bron2, bron3, bron4: std_logic_vector (3 downto 0);
    signal rb1, rb2, rb3, rb4: std_logic;
    signal lbron_1, lbron_2, lbron_3, lbron_4: std_logic_vector(3 downto 0);

begin

    -- BEGIN contadores jogador -- 
    count_1: binary_counter port map ( -- Unidade centésimos
        clock   => clock,  
        clear   => clear,  
        load    => preset or (enable and (fischer or bron)),
        enable  => enable and not(fischer) and not(bron),
        sentido => '1',
        decade  => '1',
        l       => load1,
        q       => qi1,
        rco     => rco1
    );   
    count_2: binary_counter port map ( -- Dezena centésimos
        clock   => clock,  
        clear   => clear,  
        load    => preset or (enable and (fischer or bron)),   
        enable  => rco1 and enable and not(fischer) and not(bron),
        sentido => '1',
        decade  => '1',
        l       => load2,
        q       => qi2,
        rco     => rco2
    );
    count_3: binary_counter port map ( -- Unidade segundos
        clock   => clock,  
        clear   => clear,  
        load    => preset or (enable and (fischer or bron)),   
        enable  => rco2 and enable and not(fischer) and not(bron),
        sentido => '1',
        decade  => '1',
        l       => load3,
        q       => qi3,
        rco     => rco3
    ); 
    count_4: binary_counter port map ( -- Dezena segundos
        clock   => clock,  
        clear   => clear,  
        load    => preset or (enable and (fischer or bron)),   
        enable  => rco3 and enable and not(fischer) and not(bron),
        sentido => '1',
        decade  => '1',
        l       => load4,
        q       => qi4,
        rco     => rco4
    );    
    count_5: binary_counter port map ( -- Unidade minutos
        clock   => clock,  
        clear   => clear,  
        load    => preset or (enable and (fischer or bron)),   
        enable  => rco4 and enable and not(fischer) and not(bron),
        sentido => '1',
        decade  => '1',
        l       => load5,
        q       => qi5,
        rco     => rco5
    ); 
    count_6: binary_counter port map ( -- Dezena minutos
        clock   => clock,  
        clear   => clear,  
        load    => preset or (enable and (fischer or bron)),   
        enable  => rco5 and enable and not(fischer) and not(bron),
        sentido => '1',
        decade  => '1',
        l       => load6,
        q       => qi6,
        rco     => rco6
    ); 
    -- END contadores jogador -- 


    -- -- Contadores para o método de Bronstein: conta quando o jogador não está selecionado
    -- --  p/ adicinar o valor no final
    -- bron_counter1: binary_counter port map(
    --     clock   => clock,  
    --     clear   => not(enable),  
    --     load    => '0',   
    --     enable  => enable,
    --     sentido => '0',
    --     decade  => '1',
    --     l       => "0000",
    --     q       => bron1,
    --     rco     => rb1
    -- );
    -- -- clock, not(enable), '0', enable1, '0', '1', "0000", bron1_1, r11);
    -- bron_counter2: binary_counter port map(
    --     clock   => clock,  
    --     clear   => not(enable),  
    --     load    => '0'',   
    --     enable  => rb1 and enable,
    --     sentido => '0',
    --     decade  => '1',
    --     l       => "0000",
    --     q       => bron2,
    --     rco     => rb2
    -- );    
    -- -- clock, not(enable), '0', enable1 and r11, '0', '1', "0000", bron1_2, r12);
    -- bron_counter3: binary_counter port map(
    --     clock   => clock,  
    --     clear   => not(enable),  
    --     load    => '0'',   
    --     enable  => rb2 and enable,
    --     sentido => '0',
    --     decade  => '1',
    --     l       => "0000",
    --     q       => bron3,
    --     rco     => rb3
    -- );    
    -- -- clock, not(enable), '0', enable1 and r11 and r12, '0', '1', "0000", bron1_3, open);
    -- bron_counter4: binary_counter port map(
    --     clock   => clock,  
    --     clear   => not(enable),  
    --     load    => '0'',   
    --     enable  => rb3 and enable,
    --     sentido => '0',
    --     decade  => '1',
    --     l       => "0000",
    --     q       => bron4,
    --     rco     => rb4
    -- );
    -- -- Somador para o método de Bronstein
    -- bron_add1: somadorBCD port map(q, bron1_3, '0', coutb, lbron_1);
    -- bron_add2: somadorBCD port map(q1_3, bron1_3, '0', coutb, lbron_1);
    -- bron_add3: somadorBCD port map(q1_3, bron1_3, '0', coutb, lbron_1);
    -- bron_add4: somadorBCD port map(q1_3, bron1_3, '0', coutb, lbron_1);

    -- Somadores para o método de Fischer
    fis_add1: somadorBCD port map(qi3, delta1, '0', cout1, lfischer_1);
    fis_add2: somadorBCD port map(qi4, delta2, cout1, cout2, lfischer_2);
    fis_add3: somadorBCD port map(qi5, "0000", cout2, cout3, lfischer_3);
    fis_add4: somadorBCD port map(qi6, "0000", cout3, open, lfischer_4);
    
    
    -- Load com o valor anterior + delta quando não estiver selecionado
    load1 <= "0000" when preset = '1' else
                -- lfischer_1 when fischer = '1' else
                -- lbron_1 when (bron = '1' and (lbron_3 < delta1) and (lbron_4 < delta2)) else
                qi1;

    load2 <= "0000" when preset = '1' else
                -- lfischer_2 when fischer = '1' else
                -- lbron_2 when (bron = '1' and (lbron_3 < delta1) and (lbron_4 < delta2)) else
                qi2;

    load3 <= "0000" when preset = '1' else
                lfischer_1 when fischer = '1' else
                -- lbron_3 when (bron = '1' and (lbron_3 < delta1) and (lbron_4 < delta2)) else
                -- delta1 when (bron = '1') else
                qi3;

    load4 <= "0000" when preset = '1' else
                lfischer_2 when fischer = '1' else
                qi4;

    load5 <= preset1 when preset = '1' else
                lfischer_3 when fischer = '1' else
                qi5;
                     
    load6 <= preset2 when preset = '1' else
                lfischer_4 when fischer = '1' else
                qi6;
    
    
    
    q1 <= qi1;
    q2 <= qi2;
    q3 <= qi3;
    q4 <= qi4;
    q5 <= qi5;
    q6 <= qi6;
end architecture;

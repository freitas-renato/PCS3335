-- unidadeDeControle.vhd
-- FSM que controla o jogo
-- método de Bronstein não implementado

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


entity unidadeDeControle is
    port(
        clock_out: out std_logic; -- Clock out pra debug
        
        clock:    in std_logic;
        reset:    in std_logic;

        -- Botões controle
        start:    in std_logic;
        direita:  in std_logic;
        esquerda: in std_logic;
        -- btn_J1:   in std_logic;
        -- btn_J2:   in std_logic;
        visual:   in std_logic;

        -- Saida displays e LEDs
        d1, d2, d3, d4, d5, d6: out std_logic_vector(6 downto 0);
        led1, led2: out std_logic

    );
end unidadeDeControle;

architecture comportamental of unidadeDeControle is
    component fluxoDeDados is
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
    
    end component;

    component setesegmentos is
        port(
            entrada: in std_logic_vector(3 downto 0);
            saida:  out std_logic_vector(6 downto 0)
        );
    end component;

    type state_t is (
        INICIO, 
        TEMPO, 
        MODO, 
        DELTA, 
        IDLE, 
        JOGADOR1, JOGADOR2, 
        L_FISCHER1, L_FISCHER2,
        GAME_PAUSE, OVER
    );
    signal estado_atual: state_t := INICIO;
    signal prox_estado:  state_t := TEMPO;

    signal pause:  std_logic := '1';
    signal preset: std_logic := '0';
    signal seletor:std_logic := '0';
    signal fischer, bron: std_logic := '0';
    signal fim: std_logic;

    signal delta1, delta2:   std_logic_vector (3 downto 0) := "0000";
    signal preset1, preset2: std_logic_vector (3 downto 0) := "0000";
    signal modojogo: std_logic_vector (1 downto 0) := "00";
    
    signal q1, q2, q3, q4, q5, q6: std_logic_vector (6 downto 0);
    
    -- Transformar os sinais em 7 segmentos
    signal preset1_7, preset2_7: std_logic_vector (6 downto 0);
    signal delta1_7, delta2_7  : std_logic_vector (6 downto 0);
    signal modojogo_7:           std_logic_vector (6 downto 0);

begin
    dados: fluxoDeDados port map(
        clock_out   => clock_out,
        clock       => clock,
        enable      => not(pause),
        clear       => reset,
        preset      => preset,
        seletor     => seletor,
        modo        => visual,
        fischer     => fischer,
        bron        => bron,
        delta1      => delta1,
        delta2      => delta2,
        preset1     => preset1,
        preset2     => preset2,
        fim         => fim,
       
        d1_7=>q1, d2_7=>q2, d3_7=>q3, d4_7=>q4, d5_7=>q5, d6_7=>q6
    );

    -- Process sensível apenas aos botões,
    -- muda de estado com o start
    FSM: process (start, reset, direita, esquerda, fim) 
    begin
        if (start = '1') then
            estado_atual <= prox_estado;
        elsif (reset = '1') then
            estado_atual <= INICIO;
            prox_estado <= TEMPO;
        elsif (fim = '1') then
            estado_atual <= OVER;
        end if;

        case estado_atual is
            when INICIO =>
                prox_estado <= TEMPO;
                
                preset1 <= "0000";
                preset2 <= "0011";

                delta1 <= "0101";
                delta2 <= "0000";
            
            -- Seleciona o tempo inicial
            when TEMPO =>
                prox_estado <= MODO;

                if (direita = '1') then
                    preset1 <= preset1 + "0001";
                    if (preset1 = "1010") then
                        preset1 <= "0000";
                        preset2 <= preset2 + "0001";
                    end if;
                elsif (esquerda = '1') then
                    if (preset1 = "0000") then 
                        preset1 <= "1001";
                        preset2 <= preset2 - "0001";
                    else 
                        preset1 <= preset1 - "0001";
                    end if;
                end if;
            
            -- Seleciona o modo de jogo: 0-normal, 1-fischer, 2-bronstein
            when MODO =>
                prox_estado <= DELTA;
                
                if (direita = '1') then
                    modojogo <= modojogo + "01";
                    if (modojogo = "11") then
                        modojogo <= "00";
                    end if;
                elsif (esquerda = '1') then
                    modojogo <= modojogo - "01";
                    if (modojogo = "11") then
                        modojogo <= "10";
                    end if;
                end if;
            
            -- Seleciona o valor do delta
            when DELTA =>
                prox_estado <= IDLE;

                if (direita = '1') then
                    delta1 <= delta1 + "0001";
                    if (delta1 = "1010") then
                        delta1 <= "0000";
                        delta2 <= delta2 + "0001";
                    end if;
                elsif (esquerda = '1') then
                    if (delta1 = "0000") then 
                        delta1 <= "1001";
                        delta2 <= delta2 - "0001";
                    else 
                        delta1 <= delta1 - "0001";
                    end if;
                end if;

            -- Jogo fica parado até apertar 'start', mostrando os valores iniciais
            when IDLE =>
                prox_estado <= JOGADOR1;
            
            when JOGADOR1 =>
                -- Nao depende do "start" pra mudar de estado,
                -- muda instantaneamente qnd aperta o botão
                if (direita = '1') then
                    estado_atual <= L_FISCHER1;
                elsif (esquerda = '1') then
                    estado_atual <= JOGADOR1;
                else
                    -- Apertar "start" leva pro GAME_PAUSE
                    prox_estado <= GAME_PAUSE;
                end if;
            
            when L_FISCHER1 =>
                estado_atual <= JOGADOR2;
            
            when L_FISCHER2 =>
                estado_atual <= JOGADOR1;

            when JOGADOR2 =>
                -- Nao depende do "start" pra mudar de estado,
                -- muda instantaneamente qnd aperta o botão
                if (esquerda = '1') then
                    estado_atual <= L_FISCHER2;
                elsif (direita = '1') then
                    estado_atual <= JOGADOR2;
                else
                    -- Apertar "start" leva pro GAME_PAUSE
                    prox_estado <= GAME_PAUSE;
                end if;

            when GAME_PAUSE =>
                -- "seletor" é pra saber o estado que tava antes
                if (direita = '1' or seletor = '1') then
                    prox_estado <= JOGADOR2;
                elsif (esquerda = '1' or seletor = '0') then
                    prox_estado <= JOGADOR1;
                else
                    prox_estado <= GAME_PAUSE;
                end if;
            
            when OVER =>
                -- Fica parado aqui até o reset
                prox_estado <= OVER;
            
            when others =>
                prox_estado <= INICIO;
            
            end case;
    end process FSM;
    
    -- Seleção dos sinais de controle
    with estado_atual select pause <=
        '0' when JOGADOR1 | JOGADOR2,
        '1' when others;

    with estado_atual select preset <= 
        '1' when IDLE,
        '0' when others;
    
    with estado_atual select seletor <=
        '0' when JOGADOR1,
        '1' when JOGADOR2,
		  '0' when others;
    
    with estado_atual select fischer <=
        '1' when L_FISCHER1 | L_FISCHER2,
        '0' when others;
                    
    
    -- Selção das saídas para os displays 7 segmentos
    with estado_atual select d1 <=
        preset1_7  when TEMPO,
        delta1_7   when DELTA,
        modojogo_7 when MODO,
        q1         when JOGADOR1 | JOGADOR2 | GAME_PAUSE | IDLE | OVER,
        "1111111"  when others;

    with estado_atual select d2 <=
        preset2_7  when TEMPO,
        delta2_7   when DELTA,
        q2         when JOGADOR1 | JOGADOR2 | GAME_PAUSE | IDLE | OVER,
        "1111111"  when others;

    with estado_atual select d3 <=
        q3         when JOGADOR1 | JOGADOR2 | GAME_PAUSE | IDLE | OVER,
        "1111111"  when others;

    with estado_atual select d4 <=
        q4         when JOGADOR1 | JOGADOR2 | GAME_PAUSE | IDLE | OVER,
        "1111111"  when others;

    with estado_atual select d5 <=
        q5         when JOGADOR1 | JOGADOR2 | GAME_PAUSE | IDLE | OVER,
        "1111111"  when others;
    
    with estado_atual select d6 <=
        q6         when JOGADOR1 | JOGADOR2 | GAME_PAUSE | IDLE | OVER,
        "1111111"  when others;

    -- Conversões para 7 segmentos dos sinas auxiliares 
    conv1: setesegmentos port map(preset1, preset1_7);
    conv2: setesegmentos port map(preset2, preset2_7);
    conv3: setesegmentos port map(delta1, delta1_7);
    conv4: setesegmentos port map(delta2, delta2_7);
    conv5: setesegmentos port map(("00" & modojogo), modojogo_7);
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity toplevel is
    port(
        clk: in std_logic;
        saida_tx: out std_logic;
        clock_9600: out std_logic;
        start_btn: in std_logic;
        led: out std_logic
        
    );
end toplevel;

architecture comportamental of toplevel is
    component serial is
        port(
            clk: in std_logic;
            ch:  in std_logic_vector (6 downto 0);
            st:  in std_logic;
            rd:  out std_logic;
            tx:  out std_logic
        );
    end component;

    component divisor_9600 is
        port(
            clk:   in std_logic;
            clk_out: out std_logic
        );
    end component;

    component ascii_counter is
        port(
            clk:    in std_logic;
            enable: in std_logic;
            count:  out std_logic_vector(6 downto 0)
        );
    end component;
    
    signal clock_div: std_logic;
    signal clk_cont: std_logic;

    signal caracter:  std_logic_vector(6 downto 0);
    signal start: std_logic:='0';
    signal ready: std_logic;
    
    signal P:     std_logic_vector(6 downto 0) := "1010000";
    signal C:     std_logic_vector(6 downto 0) := "1000011";
    signal S:     std_logic_vector(6 downto 0) := "1010011";
    signal n:     std_logic_vector(6 downto 0);
    signal enter: std_logic_vector(6 downto 0) := "0001010";
    signal r:     std_logic_vector(6 downto 0) := "0001101";

    type state_t is (
        INICIO, TP, TC, TS, TN, TEnter, TR
    );

    signal estado_atual: state_t := INICIO;
    signal prox_estado: state_t := TP;
    signal saida: std_logic;  



begin
    div:        divisor_9600 port map(clk, clock_div);
    count:      ascii_counter port map(clk_cont, '1', n);
    t_serial:   serial port map(clock_div, caracter, start, ready, saida);

    p1: process(ready) begin
        if (ready = '1') then
            estado_atual <= prox_estado;
        end if;

        case estado_atual is
            when INICIO =>
                start <= not(start_btn);

                if start = '1' then
                    prox_estado <= TP;
                else 
                    prox_estado <= INICIO;
                end if;

            
            when TP =>
                caracter <= P;
                -- start <= not(start_btn);

                -- if ready = '1' then
                    -- start <= '0';
                    prox_estado <= TC;
                -- else
                    -- prox_estado <= TP;
                -- end if;
            
            when TC =>
                caracter <= C;
                -- start <= not(start_btn);

                -- if ready = '1' then
                    -- start <= '0';
                    prox_estado <= TS;
                -- else
                    -- prox_estado <= TC;
                -- end if;

            when TS =>
                caracter <= S;
                -- start <= not(start_btn);

                -- if ready = '1' then
                    -- start <= '0';
                    prox_estado <= TN;
                -- else
                --     prox_estado <= TS;
                -- end if;

            when TN =>
                caracter <= n;
                -- start <= not(start_btn);

                -- if ready = '1' then
                    -- start <= '0';
                    clk_cont <= '1';
                    prox_estado <= TEnter;
                -- else
                --     prox_estado <= TN;
                -- end if;
            
            when TEnter =>
                caracter <= enter;
                -- start <= not(start_btn);
                clk_cont <= '0';
                -- if ready = '1' then
                    -- start <= '0';
                    prox_estado <= TR;
                -- else
                --     prox_estado <= TEnter;
                -- end if;
            
            when TR =>
                caracter <= r;
                prox_estado <= INICIO;
        end case;           
    end process p1;

    clock_9600 <= clock_div;
    led <= saida;
    saida_tx <= saida;

end architecture;

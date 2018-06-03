library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity serial is 
    port (
        -- Clock
        clk: in std_logic;

        -- Caractere a ser transmitido
        ch: in std_logic_vector (6 downto 0);
        
        -- "start": Sinal para iniciar a transmissão
        st: in std_logic;
        
        -- "ready": indica que o caractere foi transmitido
        rd: out std_logic;
        
        -- Saida serial
        tx: out std_logic
    );
end serial;

architecture comportamental of serial is
    type state_t is (
        INICIO,
        START_BIT,
        TRANSMISSAO0, TRANSMISSAO1, TRANSMISSAO2, TRANSMISSAO3, TRANSMISSAO4, TRANSMISSAO5, TRANSMISSAO6,
        STOP_BIT
        );

    signal estado_atual: state_t := INICIO;
    signal prox_estado: state_t:=START_BIT;
	 signal caractere: std_logic_vector(6 downto 0);
    signal enviados: integer := 0;


begin
    
    p1: process(clk) begin
        if (rising_edge(clk)) then
            estado_atual <= prox_estado;
        end if;

        case estado_atual is 
            when INICIO =>
                rd <= '1';
                tx <= '1';
                enviados <= 0;
                if st = '1' then
                    caractere <= ch;
                    prox_estado <= START_BIT;
                else    
                    prox_estado <= INICIO;
                end if;

            when START_BIT =>
                rd <= '0';
                tx <= '0';
                prox_estado <= TRANSMISSAO0;

            -- when TRANSMISSAO =>
            --     rd <= '0';
            --     tx <= caractere(enviados);
                
            --     if enviados = 7 then
            --         prox_estado <= STOP_BIT;
            --     else
            --         enviados <= enviados + 1;
            --         prox_estado <= TRANSMISSAO;
            --     end if;
            
            when TRANSMISSAO0 =>
                rd <= '0';
                tx <= caractere(0);
                prox_estado <= TRANSMISSAO1;
            
            when TRANSMISSAO1 =>
                rd <= '0';
                tx <= caractere(1);
                prox_estado <= TRANSMISSAO2;
            
            when TRANSMISSAO2 =>
                rd <= '0';
                tx <= caractere(2);
                prox_estado <= TRANSMISSAO3;
            
            when TRANSMISSAO3 =>
                rd <= '0';
                tx <= caractere(3);
                prox_estado <= TRANSMISSAO4;

            when TRANSMISSAO4 =>
                rd <= '0';
                tx <= caractere(4);
                prox_estado <= TRANSMISSAO5;

            when TRANSMISSAO5 =>
                rd <= '0';
                tx <= caractere(5);
                prox_estado <= TRANSMISSAO6;

            when TRANSMISSAO6 =>
                rd <= '0';
                tx <= caractere(6);
                prox_estado <= STOP_BIT;
            
            when STOP_BIT =>
                rd <= '0';
                tx <= '1';
                prox_estado <= INICIO;

            when others =>
                prox_estado <= INICIO;
            end case;
    end process p1;
end architecture;

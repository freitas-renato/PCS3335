library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


entity ascii_counter is
    port(
        clk:    in std_logic;
        enable: in std_logic;
        count:  out std_logic_vector(6 downto 0)
    );
end ascii_counter;

architecture comportamental of ascii_counter is
    signal q0: std_logic_vector(3 downto 0) := "0000";


begin
    process(clk) begin
        if q0 = "1010" then
            q0 <= "0000";
        elsif rising_edge(clk) then
            q0 <= q0 + "0001";
        end if;

    end process;

    count <= "011" & q0;

end architecture;
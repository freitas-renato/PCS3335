library ieee;
use ieee.std_logic_1164.all;

entity somador1b is
    port(
        x, y, cin: in std_logic;
        cout, s:   out std_logic
    );
end somador1b;

architecture comportamental of somador1b is
begin
    s    <= x xor y xor cin;
    cout <= (x and y) or (cin and x) or (cin and y);
end architecture;
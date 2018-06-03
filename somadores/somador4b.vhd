library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity somador4b is
port (
	a,b : in std_logic_vector(3 downto 0);
	cin : in std_logic;
	cout : out std_logic;
	soma : out std_logic_vector(3 downto 0));
end entity;

architecture comportamental of somador4b is

component somador1b is
port (
	x,y,cin : in std_logic;
	cout, s: out std_logic);
end component;

signal cin1, cin2, cin3 : std_logic;

begin
	
	s1: somador1b port map (a(0), b(0), cin, cin1, soma(0));
	s2: somador1b port map (a(1), b(1), cin1, cin2, soma(1));
	s3: somador1b port map (a(2), b(2), cin2, cin3, soma(2));
    s4: somador1b port map (a(3), b(3), cin3, cout, soma(3));

end architecture;
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.ALL;
use ieee.std_logic_unsigned.ALL;

-- Resuldado da soma é dado em BCD, com ajuste e carry out
entity somadorBCD is
    Port( abcd : in  std_logic_vector (3 downto 0);
           bbcd : in  std_logic_vector (3 downto 0);
           cinbcd : in  std_logic;
           coutbcd : out  std_logic;
           s : out  std_logic_vector (3 downto 0)
        );
end somadorBCD;

architecture comportamental of somadorBCD is
    component somador4b is
        port (
            a,b : in std_logic_vector(3 downto 0);
            cin : in std_logic;
            cout : out std_logic;
            soma : out std_logic_vector(3 downto 0));
    end component;

-- component bit4add is
--     Port ( ad : in  std_logic_vector (3 downto 0);
--            bd : in  std_logic_vector (3 downto 0);
--            out1 : out  std_logic_vector (3 downto 0);
--            cind : in  std_logic;
--            coutd : out  std_logic);
-- end component;
signal sout,him:std_logic_vector(3 downto 0);
signal cout1,him1,a:std_logic;
begin
BADD1: somador4b port map(abcd,bbcd,cinbcd,cout1,sout);

him1 <= (cout1 or  (sout(3)and sout(2)) or (sout(3) and sout(1)));

   with him1 select
      him <= "0110" when '1',
              "0000" when others;

BADD2: somador4b port map(him,sout,'0',coutbcd,s);

end architecture;

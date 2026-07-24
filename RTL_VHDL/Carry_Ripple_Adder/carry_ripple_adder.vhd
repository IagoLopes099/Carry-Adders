library ieee;

use ieee.std_logic_1164.all;

entity carry_ripple_adder is 
    generic(
        WIDTH : positive := 4
    );
    port(
        in_a        :   in  std_logic_vector(WIDTH-1 downto 0);
        in_b        :   in  std_logic_vector(WIDTH-1 downto 0);
        in_cin      :   in  std_logic;
        out_sum     :   out std_logic_vector(WIDTH-1 downto 0);
        out_cout    :   out std_logic
    );
end entity carry_ripple_adder;

architecture main of carry_ripple_adder is

    --  chain of carrys
    signal carry : std_logic_vector(WIDTH downto 0);

begin

    carry(0) <= in_cin;

    out_cout <= carry(WIDTH);

    gen_full_adders : for i in 0 to WIDTH -1 generate
        full_adder_inst : entity work.full_adder
        port map (
            a    => in_a(i),
            b    => in_b(i),
            cin  => carry(i),
            sum  => out_sum(i),
            cout => carry(i + 1)
        );
    end generate gen_full_adders;

end architecture main ; -- main
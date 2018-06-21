
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity vgapixel is
  Port ( clk : in  STD_LOGIC;
         status_mouse : in STD_LOGIC_VECTOR (7 downto 0);
         x_mouse : in STD_LOGIC_VECTOR (7 downto 0);
         y_mouse : in STD_LOGIC_VECTOR (7 downto 0);
         initok_mouse : in STD_LOGIC;
         datardy_mouse : in STD_LOGIC;
         map_data : in STD_LOGIC;
         map_outaddr : out STD_LOGIC_VECTOR (11 downto 0);
         red : out  STD_LOGIC;
         grn : out  STD_LOGIC;
         blu : out  STD_LOGIC;
         hs : out  STD_LOGIC;
         vs : out  STD_LOGIC);
end vgapixel;

architecture Behavioral of vgapixel is

signal horz_counter: integer := 0; -- licznik poziomu
signal vert_counter: integer := 0; -- licznik pionu
signal offsetX : integer := 0; -- przesuniecie x kursora
signal offsetY : integer := 0; -- przesuniecie y kursora
signal x_position : integer := 730; -- pozycja x startowa
signal y_position : integer := 270; -- pozycja y startowa
signal cursorSize : integer := 10; -- szer/wys kursora
signal upboundScreen : integer := 20; -- gorna granica ekranu
signal downboundScreen : integer := 650; -- gorna granica ekranu
signal leftboundScreen : integer := 150; -- gorna granica ekranu
signal rightboundScreen : integer := 1020; -- gorna granica ekranu
signal addrroundx : STD_LOGIC_VECTOR (5 downto 0) := "000000"; -- adres x dla mapy rom
signal addrroundy : STD_LOGIC_VECTOR (5 downto 0) := "000000"; -- adres y dla mapy rom
signal lose : STD_LOGIC := '0';
signal win : STD_LOGIC := '0';
type rom_block is array (0 to 37 * 64 - 1) of STD_LOGIC;

begin
   addrroundx <= std_logic_vector(to_unsigned(horz_counter, 10)(9 downto 4));
   addrroundy <= std_logic_vector(to_unsigned(vert_counter, 10)(9 downto 4));
   map_outaddr <= addrroundy & addrroundx;

   moveMouse : process (clk, x_mouse, y_mouse, datardy_mouse)
   begin
      offsetX <= to_integer(signed(x_mouse));
      offsetY <= to_integer(signed(y_mouse));
      if rising_edge( clk ) AND datardy_mouse = '1' then 
         if (x_position + offsetX) > leftboundScreen + cursorSize / 2 AND (x_position + offsetX) < rightboundScreen - cursorSize / 2 then 
            x_position <= x_position + offsetX;
         end if;
         if (y_position - offsetY) > upboundScreen + cursorSize / 2 AND (y_position - offsetY) < downboundScreen - cursorSize / 2 then 
            y_position <= y_position - offsetY;
         end if;
      end if;
   end process moveMouse; 
   
   
   showGraphics : process(clk, map_data)
   begin
      -- czyszczenie ekranu
      blu <= '0';
      grn <= '0';
      red <= '0';
      
      -- jesli wygrana
      if win = '1' then
         grn <= '1';
      end if;
      
      -- jesli przegrana
      if lose = '1' then
         red <= '1';
      end if;
      
      -- rysoawnie mapy dla pamieci rom
      if map_data = '1' then
         red <= '1';
         blu <= '0';
         grn <= '0';
      end if; 
      
      -- jesli kolizja
      if map_data = '1' 
         and y_position + (cursorSize / 2) > vert_counter 
         and y_position - (cursorSize / 2) < vert_counter        
         and x_position + (cursorSize / 2) > horz_counter             
         and x_position - (cursorSize / 2) < horz_counter 
         then  
            lose <= '1';
      end if;
      
      -- kursor myszki
      if vert_counter > y_position - (cursorSize / 2) 
         and vert_counter < y_position + (cursorSize / 2)
         and horz_counter > x_position - (cursorSize / 2)
         and horz_counter < x_position + (cursorSize / 2) 
         then
         red <= '1';
         blu <= '1';
         grn <= '1';
      end if; 
      

      -- granice ekranu
      if vert_counter = upboundScreen then
         red <= '1';
      elsif vert_counter = downboundScreen then
         blu <= '1';
      elsif horz_counter = leftboundScreen then
         grn <= '1';
      elsif horz_counter = rightboundScreen then
         blu <= '1';
         grn <= '1';
      end if;
      
   end process showGraphics;   
   
   refresh : process(clk)
   begin
    if clk = '1' and clk'event then
      if horz_counter < 121 and horz_counter >= 0 then
         hs <= '1';
      else
         hs <= '0';
      end if;
      if vert_counter < 7 and vert_counter >= 0 then
         vs <= '1';
      else
         vs <= '0';
      end if;
    
      -- Liczniki poziome i pionowe
      horz_counter <= horz_counter + 1;
	   if horz_counter >= 1040 then
         horz_counter <= 0;
         vert_counter <= vert_counter + 1;
		end if;
      
      if vert_counter >= 666 then
         vert_counter <= 0; 
      end if;
      
	 end if;
  end process refresh;
  
end Behavioral;
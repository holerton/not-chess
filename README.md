
# Name: to be determined (not chess?)

This game was initially developed for chessboard and with chess figures. It may be endless, but who says that's wrong?


# Rules

There are two modes: *classic* (original game, you are able to play it with your chess set) and *natural* (extends basic game with some more or less realistic features). You should familiarize yourself with classic game first, as there is no distinct rulebook for natural mode because of the fact that almost all game concepts from *classic* mode apply to *natural* as well.

## *Classic* mode rules

The setting is a standard 8x8 chessboard with initial position like this: 

<p align="center">
  <img src="https://raw.githubusercontent.com/holerton/not-chess/master/readme_images/board_initial.bmp" />
</p>

There are two Kings, being referenced as "capitals", and a capital of each player is main goal for another. 
Two types of figures you can place to the board:

 1. Pawn
 2. War Figure

You win if one of your "War Figures" (Rook, Bishop, (k)Night) reaches enemy's capital.

## *Natural* mode rules

>Я напiшу толькi што трэба пакуль што 
Так выглядаюць developer notes

### Nomads
Nomads are peaceful people who travel through your battlefield. You can't attack them and can't shoot over them, cause you know what angry nomads can do...
<p align="center">
  <img src="https://upload.wikimedia.org/wikipedia/commons/e/ea/Mongol_Empire_map.gif" />
</p>

### Seasons

> Павiнны быць нейкiя поры года каб снег заўсёды не ляжаў, мабыць змена раз у 4 хады, каб яшчэ была такая логiка што качэўнiкi таксама неяк залежаць ад надвор'я

### Terrain and weather
Terrain and weather both influence figures' movement, but terrain is static and weather is moving.

 - ### Terrain types
> у парадку панiжэньня верагоднасьцi ўзнiкненьня
 1. Plain (it's plain); LAWN_GREEN
 2. Forest (archers can not shoot from forest, riders can not enter forest at all); FOREST_GREEN
 3. Water: only ships can move on the water; DODGER_BLUE
 4. Desert: rooks and archers skip turn after they step on this type of terrain (riders effectively change their horses to camels); CORNSILK
 5. Marshes: rider gets -1 movement of what he has when he enters one of this types of terrain; DARK_OLIVE_GREEN
 6. Mountain: any figure (including nomads) skips turn after it steps on this type of terrain. DARK_GRAY
> колер выбару: DARK_ORCHID
> колер атакi: CRIMSON

 - ### Weather types
 1. Flood: same as swamp;
2. Snow: all figures except archers have -1 movement (and so they can be forced to skip their turn) (archers are light)
 3. Rain: archers have 0.3 chance to miss;
4. Wind: riders have +1 movement if they ride all way straight with the direction of the wind; archers have 0.1 chance to miss independently of wind direction;
  <p align="center">
  <img src="https://raw.githubusercontent.com/holerton/not-chess/master/readme_images/board_horse_mov.bmp" />
</p>

5. Drought: same as desert.

> магчыма гэта ня ўсё, напрыклад буры на моры якiя ламаюць бедных караблiкаў
 ### About Terrain generation
 Што я прыдумаў. \
 Уваход: колькасьць клетак кожнага тыпу:
 -  p,f,w,d,s(wamp),m
  - Памер дошкі (size)
  
Вызначаем колькасьць блокаў кожнага тыпу (мноства квадрацікаў, звязаных па старане).
Для кожнага тыпу * колькасьць блокаў
<p align="center">
$$k_*$$
</p>
вызначаецца ў межах
<p align="center">
$$k_*^{min} - k_*^{max}$$
</p>
у залежнасьці ад тыпу і size (усё float):
<p align="center">
$$k_p^{min}=ln(size)-2 \quad \quad k_p^{max}=\frac {size} {16}$$
</p>
<p align="center">
$$k_p^{min}=ln(size)-2 \quad \quad k_p^{max}=\frac {size} {16}$$
</p>
<p align="center">
$$k_f^{min}=ln(size)-3 \quad \quad k_f^{max}=\frac {size} {10}$$
</p>
<p align="center">
$$k_w^{min}=ln(size)-3 \quad \quad k_w^{max}=\frac {size} {10}$$
</p>
<p align="center">
$$k_d^{min}=ln(size)-4 \quad \quad k_d^{max}=\frac {size} {32}$$
</p>
<p align="center">
$$k_s^{min}=ln(size)-4 \quad \quad k_s^{max}=\frac {size} {32}$$
</p>
<p align="center">
$$k_m^{min}=ln(size)-4 \quad \quad k_m^{max}=\frac {size} {32}$$
</p>

Цяпер мы маем * ,  $k_*^{min}$, $k_*^{max}$.
Трэба выясніць колькі ўсяго блокаў і колькі ў кожным блоку квадрацікаў. Гэта можна зрабіць паралельна:
Падлічваем
<p align="center">
$$k_*^{avg}=\frac {k_*^{min}+k_*^{max}} {2} (float)$$
</p>
<p align="center">
$$k_*^{var}=\frac {k_*^{max}-k_*^{avg}} {3} (float)$$
</p>
   У цыкле пакуль не скончацца квадрацікі нармальна (дзякуючы ўбудаванай функцыі $ randfn(\mu,\sigma)$ ) размяркоўваем іх:
<p align="center">
$$k_*=(float) randfn(k_*^{avg},k_*^{var})$$
</p>
- лічым колькі пхаць у першы блок: $\frac {*} {k_*}$ ($ int, round $)
- калі $\frac {*} {k_*}>$ квадрацікаў засталося, то блок апошні
- інакш змяншаем $*_{засталося}$ і ідзем у пачатак
   
>   (гэта была простая частка)
> ### About Weather generation
>  - Wind considerably changes with seasons and slightly changes within seasons (randomly);
>  - Rain is formed over mountains;
>  - Snow is just rain in winter;

## List of AKAs

 - **King**: *Capital*
 - **Pawn**: *Peasant*, *Villager*, *Little*
 - **Rook**: *Warrior*, *Berserk*, *Fatman*
 - **Bishop**: *Archer*, *Cheater*
 - **Knight**: *Rider*,*Horseman*, or simply *Horse*
$ax^2 + bx + c = 0$

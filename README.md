# Name: to be determined (not chess?)

This game was initially developed for chessboard and with chess figures. It may be endless, but who says that's wrong?


# Rules

There are two modes: *classic* (original game, you are able to play it with your chess set) and *natural* (extends basic game with some more or less realistic features). You should familiarize yourself with classic game first, as there is no distinct rulebook for natural mode because of the fact that almost all game concepts from *classic* mode apply to *natural* as well.

## *Classic* mode rules

The setting is a standard 8x8 chessboard with initial position like this: 

<p align="center">
  <img src="https://raw.githubusercontent.com/holerton/not-chess/master/board_initial.bmp" />
</p>

There are two Kings, being referenced as "capitals", and a capital of each player is main goal for another. 
Two types of figures you can place to the board:

 1. Pawn
 2. War Figure

You win if one of your "War Figures" (Rook, Bishop, (k)Night) reaches enemy's capital.

## *Natural* mode rules

>Я напiшу толькi што трэба пакуль што 
> Так выглядаюць developer notes

### Nomads
Nomads are peaceful people who travel through your battlefield. You can't attack them and can't shoot over them, cause you know what angry nomads can do...
<p align="center">
  <img src="https://upload.wikimedia.org/wikipedia/commons/e/ea/Mongol_Empire_map.gif" />
</p>

> Можна зрабiць нейкiя прыколы, напрыклад калi 5 разоў тыкнеш (выпадкова цi не) на качэўнiка, то яны ўключаць "Crazy Mode" i колькасьць павялiчыцца ў 5 разоў

### Seasons

> Павiнны быць нейкiя поры года каб снег заўсёды не ляжаў, мабыць змена раз у 4 хады, каб яшчэ была такая логiка што качэўнiкi таксама неяк залежаць ад надвор'я

### Terrain and weather
Terrain and weather both influence figures' movement, but terrain is static and weather is moving.

 - ### Terrain

 1. Plain (it's plain);
 2. Forest (archers can not shoot from forest, riders can not enter forest at all);
 3. Marshes: rider gets -1 movement of what he has when he enters one of this types of terrain;
 4. Mountain: any figure (incl. nomads) skips turn after it steps on this type of terrain; 
 > 5. Sea: tbd (караблiкi!) 
 5. Desert: rooks and archers skip turn after they step on this type of terrain (riders effectively change their horses to camels);

 - ### Weather
 6. Flood: same as swamp;
 7. Snow: all figures except archers have -1 movement (and so they can be forced to skip their turn) (archers are light)
 8. Rain: archers have 0.3 chance to miss;
 9. Wind: riders have +1 movement if they ride all way straight with the direction of the wind; archers have 0.1 chance to miss independently of wind direction;
  <p align="center">
  <img src="https://raw.githubusercontent.com/holerton/not-chess/master/board.bmp" />
</p>

> магчыма гэта ня ўсё, напрыклад буры на моры якiя ламаюць бедных караблiкаў
> ### About Terrain generation
> Each type of terrain on the map must be associated with two numbers: numOf squares with this type of terrain and numOf connected spaces of this type of terrain (кажысь гэта завецца "k-связное множество")
> ### About Weather generation
>  - Wind considerably changes with seasons and slightly changes within seasons (randomly);
>  - Rain is formed over mountains;
>  - Snow is just rain in winter;
>  - Marshes in the center of desert are unwelcomed;

## List of AKAs

 - **King**: *Capital*
 - **Pawn**: *Peasant*, *Villager*, *Little*
 - **Rook**: *Warrior*, *Berserk*, *Fatman*
 - **Bishop**: *Archer*, *Cheater*
 - **Knight**: *Rider*,*Horseman*, or simply *Horse*

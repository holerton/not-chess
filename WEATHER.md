
## Seasons reminder

Each turn for one player, or each two turns game-wide, is called Month. There are 4 months in each of four seasons: Winter, Spring, Summer, Autumn. **Game starts on the first Month of Winter**.

# About Weather

Weather in the terms of the game appears as a variable Terrain type, but it does not necessarily override Terrain properties. **Weather changes each player's turn, and Weather parameters change each Month**. Weather Unit (WU) is one specific block of Weather. There are two types of Weather: moving (location of Weather Unit is dependent from location of this particular WU on the previous Month) and map-wide-random. We will start from the second type.

## Map-wide-random Weather

Map-wide-random means for each Month there are presets for this type of Weather (probability of appearing on each block of the map).

### Types
- **Snow over the Mountain**

*Effect*=Mountain+Snow  

Before the game start, and after Terrain generation, for each Mountain there is 85% probability (it is called Initial Probability) that there will be snow on top of it. Then, **before each player's turn**, we check each Mountain: does Snow appears or disappears on top of it (as for now, there are no plans of doing more than one layer of Snow).  

Order:  
	1. Check existance;  
	2. If exists, check probabilty of disappearance;  
	3. Then check probabilty of appearance for block from point (2.)  
	4. Then check probability of appearance for other blocks.  

 | Month |  Probability of appearance | Probabilty of disapperance| 
 |---------|--------------------------|---------------|
|W1nter|95|2
|W2nter|99|0
|W3nter|99|0
|W4nter|95|0
|Spr1ng|50|4
|Spr2ng|30|6
|Spr3ng|20|8
|Spr4ng|10|14
|Summe1|5|20
|Summe2|0|25
|Summe3|0|30
|Summe4|0|25
|Aut1mn|7|12
|Aut2mn|25|6
|Aut3mn|65|5
|Aut4mn|85|4

$~$

- **Ice**


*Effect*=Snow  
Appears over the Water. Works the same as a Snow over Mountain except the probabilities table.  
*Initial Probability: 50%.*

> **Note: probability of appearance is eight times less if corresponding Water block is on the edge of the map.**

| Month |  Probability of appearance | Probabilty of disapperance| 
 |---------|--------------------------|---------------|
|W1nter|70|6
|W2nter|88|0
|W3nter|96|0
|W4nter|96|0
|Spr1ng|40|15
|Spr2ng|30|25
|Spr3ng|5|60
|Spr4ng|1|80
|Summe1|1|99
|Summe2|0|99
|Summe3|0|99
|Summe4|0|99
|Aut1mn|1|75
|Aut2mn|8|50
|Aut3mn|24|30
|Aut4mn|50|15

$~$

- **Snow over the Forest/Swamp**

*Effect*=Forest+Snow (Swamp+Snow)  
*Initial Probability: 70%.*

| Month |  Probability of appearance | Probabilty of disapperance| 
 |---------|--------------------------|---------------|
|W1nter|80|2
|W2nter|93|0
|W3nter|98|0
|W4nter|98|0
|Spr1ng|50|3
|Spr2ng|32|3
|Spr3ng|7|7
|Spr4ng|2|25
|Summe1|1|96
|Summe2|0|99
|Summe3|0|99
|Summe4|0|99
|Aut1mn|3|70
|Aut2mn|14|30
|Aut3mn|46|20
|Aut4mn|70|2

$~$

- **Snow over the Plain**

*Effect*=Snow  
*Initial Probability: 70%.*

| Month |  Probability of appearance | Probabilty of disapperance| 
 |---------|--------------------------|---------------|
|W1nter|80|3
|W2nter|93|0
|W3nter|98|0
|W4nter|98|0
|Spr1ng|50|8
|Spr2ng|32|17
|Spr3ng|7|50
|Spr4ng|2|80
|Summe1|1|99
|Summe2|0|99
|Summe3|0|99
|Summe4|0|99
|Aut1mn|3|75
|Aut2mn|14|40
|Aut3mn|46|25
|Aut4mn|70|12

$~$

- **Snow over the Desert**

*Effect*= Desert + Snow  
*Initial Probability: 2%.*

| Month |  Probability of appearance | Probabilty of disapperance| 
 |---------|--------------------------|---------------|
|W1nter|5|5
|W2nter|6|0
|W3nter|6|0
|W4nter|6|0
|Spr1ng|2|8
|Spr2ng|0|17
|Spr3ng|0|50
|Spr4ng|0|80
|Summe1|0|99
|Summe2|0|99
|Summe3|0|99
|Summe4|0|99
|Aut1mn|0|75
|Aut2mn|0|40
|Aut3mn|0|25
|Aut4mn|2|12

## Moving Weather

Location of the Weather Unit depends on its location in the previous Month.

### Types

- **Rain**

*Note: Rains=Rain Weather Units, Waters=Water Weather Units etc.*

_Effect_: Archers have 0.3 chance to miss. And it's beautiful. And maybe more.

Rain generation algorithm for each month depends on two numbers: *A* - number of Rains to appear and *D* - number of Rains to disappear.  
Steps:  
1. Randomly choose *D* Rains; they disappear;
2. Move remaining Rains: if there is no Wind on start square, Rain moves to the one of the eight closest squares (randomly chosen), but it can not move to the square with the Wind direction exactly opposite to expected Rain movement direction. If there is Wind on the square, then Rain moves in the direction of Wind.
*Note: Rain can move on any square (black/white).*
3. After second step, if there is a square with two Rains, Thunderstorm is formed on that square;
4. New Rains appear:  
4.1. Try to place *A* Rains on random Mountains;  
4.2. If *R* Rains remain unplaced, try to place *R* Rains on random Waters;  
4.3. If *U* Rains remain unplaced, try to place *U* Rains on random Plains.

Rain *A*/*D* table, example from README.md (10x10 board):

| Month |  *A* | *D*| 
 |---------|--------------------------|---------------|
|W1nter|0|0
|W2nter|0|0
|W3nter|0|0
|W4nter|0|0
|Spr1ng|1|0
|Spr2ng|1|1
|Spr3ng|2|1
|Spr4ng|10|2
|Summe1|4|9
|Summe2|1|5
|Summe3|4|0
|Summe4|2|4
|Aut1mn|4|2
|Aut2mn|15|0
|Aut3mn|4|19
|Aut4mn|0|4


Rain *A*/*D* table, where *S* is a board size; *integer division everywhere*:

| Month |  *A* | *D*| 
 |---------|--------------------------|---------------|
|W1nter|0|0
|W2nter|0|0
|W3nter|0|0
|W4nter|0|0
|Spr1ng|$max \left( \frac {S} {33}-2; 1 \right) $ |0
|Spr2ng|$max \left( \frac {S} {29}-2; 1 \right) $|$max \left( \frac {S} {33}-2; 1 \right) $
|Spr3ng|$max \left( \frac {S} {22}-2; 1 \right) $|$max \left( \frac {S} {29}-2; 1 \right) $
|Spr4ng|$\frac {S} {10} $|$max \left( \frac {S} {22}-2; 1 \right) $
|Summe1|$\frac {S} {22} $| $\frac {S} {10}-1 $
|Summe2|$max \left( \frac {S} {33}-2; 1 \right) $|$\frac {S} {22}+1 $
|Summe3|$\frac {S} {18}-1$|0
|Summe4|$max \left( \frac {S} {22}-2; 1 \right) $|$\frac {S} {18}-1$
|Aut1mn|$\frac {S} {17}-1$|$max \left( \frac {S} {22}-2; 1 \right) $
|Aut2mn|$\frac {S} {7} +1$|0
|Aut3mn|$\frac {S} {17}-1$|$\frac {S} {7} +\frac {S} {17}$
|Aut4mn|0|$\frac {S} {17}-1$

$~$

- **Thunderstorm**

Special Weather type. Appears only if two Rains merge. No one can step/place on the square with Thunderstorm. **TBD**

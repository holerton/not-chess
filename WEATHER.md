
## Seasons reminder

Each turn for one player, or each two turns game-wide, is called Month. There are 4 months in each of four seasons: Winter, Spring, Summer, Autumn. **Game starts on the first Month of Winter**.

# About Weather

Weather in the terms of the game appears as a variable Terrain type, but it does not necessarily override Terrain properties. Weather Unit (WU) is one specific block of Weather. There are two types of Weather: moving (location of Weather Unit is dependent from location of this particular WU on the previous Month) and map-wide-random. We will start from the second type.

## Map-wide-random Weather

Map-wide-random means for each Month there are presets for this type of Weather (probability of appearing on each block of the map).
Ler's consider an example.
### Types
- **Snow over Mountains**
Before the game start, and after Terrain generation, for each Mountain there is 85% probability (it is called Initial Probability) that there will be snow on top of it. Then, each Month including the first one, we check each Mountain: does Snow appears or disappears on top of it (as for now, there are no plans of doing more than one layer of Snow). 
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

- **Ice**
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


## Moving Weather (planned)

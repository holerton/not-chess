 ### About Terrain generation
 Што я прыдумаў. \
 Уваход: колькасьць клетак кожнага тыпу:
 -  p,f,w,d,s(wamp),m
  - Памер дошкі (size)
  
Вызначаем колькасьць блокаў кожнага тыпу (мноства квадрацікаў, звязаных па старане).
Для кожнага тыпу * колькасьць блокаў $k^{\*}$
вызначаецца ў межах $k_{\*}^{min} - k_{\*}^{max}$
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

Цяпер мы маем \* , 
$k_{\*}^{min}$ ,
$k_{\*}^{max}$.
Трэба выясніць колькі ўсяго блокаў і колькі ў кожным блоку квадрацікаў. Гэта можна зрабіць паралельна. Падлічваем
<p align="center">
$$k_*^{avg}=\frac {k_*^{min}+k_*^{max}} {2} (float)$$
</p>
<p align="center">
$$k_*^{var}=\frac {k_*^{max}-k_*^{avg}} {3} (float)$$
</p>

У цыкле пакуль не скончацца квадрацікі нармальна (дзякуючы ўбудаванай функцыі $randfn \left( \mu,\sigma \right) $) размяркоўваем іх:

<p align="center">
$$k_*=(float) randfn(k_*^{avg},k_*^{var})$$
</p>

- лічым колькі пхаць у першы блок: $\frac {\*} {k_\*}$($int, round $)
- калі $\frac {\*} {k_\*}>$ квадрацікаў засталося, то блок апошні
- інакш змяншаем $\*_{засталося}$ і ідзем у пачатак

>   (гэта была простая частка)

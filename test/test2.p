/*
* Muestra la sucesió n de puntos de un arco de cir cunferen cia
* centrada en el origen y de radio R , comprendidos entre un
* á ngulo inicial ( en fracciones de pi ) y uno final .
*/
write ( " ### Muestra los puntos de un arco de circunferencia ###\n " ) ;
write ( " _Angulo inicial [ unidades de PI ] ... : " ) ; read ( aini ) ;
read ( " _Angulo final [ unidades de PI ] ..... : " , afin ) ;
read ( " _Radio ..... : " , radio ) ;
read ( " _Numero .... : " , NumPtos ) ;

// Obtenemos el valor de PI
PI = acos ( -1) ;

// Cálculo y normalización a circunferencia del incremento de ángulos
// No es la mejor implementación , claro ...
adelta = ( afin - aini ) / NumPtos ;
if ( adelta > 2) {
    while ( adelta > 2) {
        adelta = adelta - 2 ;
    }
}

adelta = adelta * PI ;

// Valores iniciales
n_pto = 0 ;
a_pto = aini * PI ;
x_pto = radio * cos ( a_pto ) ;
y_pto = radio * sin ( a_pto ) ;

/* Mientras no alcancemos el m á ximo de puntos a mostrar */
while ( n_pto < NumPtos ) {
    write ( " ___Punto ( " , n_pto ) ;
    write ( " ) , ángulo ( " , a_pto ) ; write ( " ) : [ " , x_pto ) ; write ( " , " , y_pto ) ;
    write ( " ]\n " ) ;
    // Siguiente elemento
    a_pto = a_pto + adelta ;
    x_pto = radio * cos ( a_pto ) ;
    y_pto = radio * sin ( a_pto ) ;
    n_pto = n_pto + 1 ;
}
/*
 * Programa sencillo
 */
write("### Muestra los elementos de una progresion aritmetica ###\n") ;
read ("_Primer elemento .......:", a_0) ;
write("_Razón .................:") ; read(razon) ;
read ("_Número de elementos ...:", nelem) ;

n_i = 0 ; a_i=a_0 ; // Inicial
while (n_i < nelem) {
    write ("___Elemento (", n_i) ; write("):  ", a_i) ; write ('\n') ;
    // Siguiente elemento
    a_i = a_i + razon ;
    n_i = n_i + 1 ;
} 
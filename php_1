<?php
echo "echo benötigt keine Klammern.";

// Strings können entweder individuell als mehrere Argumente oder
// miteinander verbunden als einzelnes Argument übergeben werden
echo 'Dieser ', 'String ', 'besteht ', 'aus ', 'mehreren Parametern.', "\n";
echo 'Dieser  ' . 'String ' . 'wurde ' . 'mit ' . 'Stringverkettung erzeugt.' . "\n";

// Es wird kein Zeilenumbruch oder Leerzeichen eingefügt; das Folgende gibt
// "HalloWelt" in einer Zeile aus
echo "Hallo";
echo "Welt";

// Dasselbe wie oben
echo "Hallo", "Welt";

echo "Dieser String umfasst
mehrere Zeilen. Die Zeilenumbrüche
werden mit ausgegeben.";

echo "Dieser String umfasst\nmehrere Zeilen. Die Zeilenumbrüche\nwerden mit ausgegeben.";

// Das Argument kann ein beliebiger Ausdruck sein, der einen String erzeugt
$foo = "ein Beispiel";
echo "foo ist $foo"; // foo ist ein Beispiel

$fruechte = ["Zitrone", "Orange", "Banane"];
echo implode(" und ", $fruechte); // Zitrone und Orange und Banane

// Nicht-String-Ausdrücke werden in String umgewandelt, auch wenn
// declare(strict_types=1) verwendet wird
echo 6 * 7; // 42

// Da echo sich nicht wie ein Ausdruck verhält, ist der folgende Code ungültig.
#($eine_variable) ? echo 'true' : echo 'false';

// Folgende Beispiele funktionieren hingegen:
($eine_variable) ? print 'true' : print 'false'; // print ist auch ein Konstrukt,
                         // aber es ist ein gültiger Ausdruck, der 1 zurückgibt,
                         // also kann es in diesem Kontext verwendet werden.

echo $eine_variable ? 'true': 'false'; // den Ausdruck zuerst auswerten und
                                       // dann an echo übergeben
?>

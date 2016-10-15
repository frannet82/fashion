<?php
session_start();
ob_start();

$host = "localhost";
$user = "root";
$pw = "z2n4p9d0e8";
$db = "fashion";

$con = mysql_connect($host,$user,$pw) or die("Problemas al conectar");
mysql_select_db($db, $con) or die("Problemas al conectar la bd");
mysql_set_charset('utf8');
?>
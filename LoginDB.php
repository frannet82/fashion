<?php
session_start();
ob_start();
if($_SESSION['Logout'] == "Logout")
{
	$_SESSION['actualUser'] = NULL;
	$_SESSION['Logout'] = NULL;
	$_SESSION['Login'] = "Login";
	header("Location: Main.php");
}
else
{
	$host = "localhost";
	$user = "root";
	$pw = "qwerty123";
	$db = "fashion";
	
	$con = mysql_connect($host,$user,$pw) or die("Problemas al conectar");
	mysql_select_db($db, $con) or die("Problemas al conectar la bd");
	mysql_set_charset('utf8');
	
	$email = $_POST["login"];
	$password = $_POST["password"];
	
	$result = mysql_query("select login('$email', '$password')");
	$row = mysql_fetch_array($result);
	$idActualUser = $row[0];
	
	if($idActualUser != NULL)
	{
		$result = mysql_query("select * from usuarios where idUsuario = '$idActualUser';");
		$row = mysql_fetch_array($result);
		$_SESSION['actualUser'] = $row["idUsuario"];
		$_SESSION['Log'] = "Logout";
		header("Location: Main.php");
	}
	else
	{
		header("Location: login.php");
	}
}
?>
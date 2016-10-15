<?php
$host = "localhost";
$user = "root";
$pw = "qwerty123";
$db = "fashion";

$con = mysql_connect($host,$user,$pw) or die("Problemas al conectar");
mysql_select_db($db, $con) or die("Problemas al conectar la bd");
mysql_set_charset('utf8');

$name = $_POST["Name"];
$firstName = $_POST["FirstName"];
$lastName = $_POST["LastName"];
$email = $_POST["Email"];
$password = $_POST["Password"];
$birth = $_POST["Birth"];
$country = $_POST["Country"];
$roles = "";

for($i = 0; $i < sizeof($_POST["Roles"]); $i++)
{
	$roles = $roles.$_POST["Roles"][$i].",";
}

mysql_query("call signUser('$name', '$firstName', '$lastName', '$birth', '$password', '$email', '$country', '$roles');");
if (!mysql_error($con))
{
	header("Location: login.php");
}
else
{
	echo mysql_error($con);
}
?>
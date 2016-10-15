<?php
include("DBConnection.php");

$date1 = $_POST["date1"];
$date2 = $_POST["date2"];
$money = $_POST["money"];
$idDesign = $_POST["id"];

mysql_query("call newSale($idDesign, '$date1', '$date2', $money);");
if (!mysql_error($con))
{
	header("Location: Main.php");
}
else
{
	echo mysql_error($con);
}

?>
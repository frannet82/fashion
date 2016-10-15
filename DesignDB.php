<?php
include("DBConnection.php");

if(isset($_POST["features"]))
{
	$Features = "";
	for($i = 0; $i < sizeof($_POST["features"]); $i++)
	{
		$Features = $Features.$_POST["features"][$i].",";
	}
}
else
{
	$Features = "";
}

if(isset($_POST["types"]))
{
	$Types = "";
	for($i = 0; $i < sizeof($_POST["types"]); $i++)
	{
		$Types = $Types.$_POST["types"][$i].",";
	}
}
else
{
	$Types = "";
}

if(($_POST["date1"]) != NULL)
{
	$Date1 = $_POST["date1"];
}
else
{
	$Date1 = "1000-1-1";
}

if(($_POST["date2"]) != NULL)
{
	$Date2 = $_POST["date2"];
}
else
{
	$Date2 = "9999-12-31";
}

if(isset($_POST["country"]))
{
	$Country = $_POST["country"];
}
else
{
	$Country = "";
}

if(($_POST["rate"]) != NULL)
{
	$Rate = $_POST["rate"];
}
else
{
	$Rate = 0;
}


mysql_query("call searchDesigns('$Features', '$Types', '$Date1', '$Date2', '$Country', $Rate);");

if (!mysql_error($con))
{
	header("Location: Design.php");
}
else
{
	echo mysql_error($con);
}
?>
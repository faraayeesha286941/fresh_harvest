<?php
$servername = "192.168.237.210";
$username   = "fara";
$password   = "pass";
$dbname     = "fresh_harvest";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
?>

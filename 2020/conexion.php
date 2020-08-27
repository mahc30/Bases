<?php
require 'Medoo.php';

use Medoo\Medoo;

$db = new Medoo([
    'database_type' => 'mysql',
    'database_name' => 'tabd',
    'server' => 'localhost',
    'username' => 'remote',
    'password' => ''
]);

?>
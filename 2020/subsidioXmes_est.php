<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SubsidioXmes</title>
</head>

<body>

    <table>
        <tr>
            <th>Mes</th>
            <th>Estrato</th>
            <th>Subsidio</th>
        </tr>
        
        <?php

        require_once('conexion.php');

        $data = $db->select(
            "subsidios",
            [
                "mes",
                "estrato",
                "subsidio"
            ],
            [
                "ORDER" => [
                    "mes",
                    "estrato"
                ]
            ]
        );

        foreach ($data as &$reg) {
            echo "<tr>";
            echo "<td>" . $reg["mes"] . "</td>";
            echo "<td>" . $reg["estrato"] . "</td>";
            echo "<td>" . $reg["subsidio"] . "</td>";
            echo "</tr>";
        }

        $db = null;
        ?>

    </table>
</body>

</html>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ValorFacturaXmes</title>
</head>


<body>
    <table>

        <tr>
            <th>Kwh</th>
            <th>Mes</th>
            <th>Municipio</th>
        </tr>

        <?php
        require_once('conexion.php');

        $data = $db->select(
            "kwh_municipio",
            [
                "kwh",
                "mes",
                "municipio"
            ],
            [
                "ORDER" => [
                    "municipio"
                ]
            ]
        );

        foreach ($data as &$reg) {
            echo "<tr>";
            echo "<td>" . $reg["kwh"] . "</td>";
            echo "<td>" . $reg["mes"] . "</td>";
            echo "<td>" . $reg["municipio"] . "</td>";
            echo "</tr>";
        }
        $db = null;
        ?>
    </table>

</body>

</html>
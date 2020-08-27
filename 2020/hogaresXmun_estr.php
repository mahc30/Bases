<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HogaresXmunicipioyEstrato</title>
</head>

<body>
    <table>
        <tr>
            <th>Municipio</th>
            <th>Estrato</th>
            <th>C_Hogares</th>
        </tr>

        <?php
        require_once('conexion.php');

        $data = $db->select(
            "total_hogares",
            [
                "municipio",
                "estrato",
                "hogares"
            ],
            [
                "ORDER" => [
                    "municipio",
                    "estrato"
                ]
            ]
        );

        foreach ($data as &$reg) {
            echo "<tr>";
            echo "<td>" . $reg["municipio"] . "</td>";
            echo "<td>" . $reg["estrato"] . "</td>";
            echo "<td>" . $reg["hogares"] . "</td>";
            echo "</tr>";
        }
        $db = null;
        ?>
    </table>

</body>

</html>
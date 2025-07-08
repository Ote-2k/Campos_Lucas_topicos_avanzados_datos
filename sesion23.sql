/*
Diseña un modelo NoSQL para el esquema curso_topicos. Documenta en comentarios cómo estructurarías los datos en MongoDB (por ejemplo, qué datos embebes y por qué). Proporciona un ejemplo de un documento

Diseño del modelo NoSQL para MongoDB basado en el esquema curso_topicos

- Colección: usuarios
- Se embeberán los pedidos directamente dentro de cada documento de cliente.
- Los productos se referenciarán por nombre y datos estáticos embebidos en cada detalle del pedido.
- Esto para optimizar lectura de reportes frecuentes sin JOINs ni múltiples colecciones.
*/

-- Documento de ejemplo en la colección usuarios
{
  "clienteId": 2001,
  "nombre": "juan juan",
  "ciudad": "Valdivia",
  "correo": "juan.juan@juan.cl",
  "pedidos": [
    {
      "pedidoId": 9001,
      "fecha": "2025-04-10",
      "total": 1845.00,
      "detalles": [
        { "productoId": 11, "nombre": "Tablet", "precio": 615.00, "cantidad": 2 },
        { "productoId": 14, "nombre": "Teclado", "precio": 205.00, "cantidad": 1 }
      ]
    }
  ]
}

/*
Escribe dos consultas en MongoDB:
a. Una para obtener los clientes de una ciudad específica (por ejemplo, Santiago).
b. Otra para calcular el número total de productos vendidos por producto.
*/

-- Mostramos nombre y ciudad de los clientes que viven en Valdivia
db.usuarios.find(
  { "ciudad": "Valdivia" },
  { "nombre": 1, "ciudad": 1, "_id": 0 }
);

/*
resultado esperado
{ "nombre": "juan juan", "ciudad": "Valdivia" }
{ "nombre": "Luis Castro", "ciudad": "Valdivia" }
*/

-- Número total de productos vendidos por producto
db.usuarios.aggregate([
  { $unwind: "$pedidos" },
  { $unwind: "$pedidos.detalles" },
  {
    $group: {
      _id: "$pedidos.detalles.nombre",
      totalVendidos: { $sum: "$pedidos.detalles.cantidad" }
    }
  }
]);


/*
Resultado esperado:
{ "_id": "Tablet", "totalVendidos": 4 }
{ "_id": "Teclado", "totalVendidos": 2 }
*/
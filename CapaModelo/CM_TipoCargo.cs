namespace CapaModelo
{
    public class CM_TipoCargo
    {
        /*CREATE TABLE tipo_cargo
            (
             id_tipo INTEGER NOT NULL IDENTITY(1,1),
             nombre  VARCHAR(150) NOT NULL,
             monto   DECIMAL(30,3) NOT NULL,
             estado  BIT NOT NULL
            )*/
        public int id_tipo { get; set; }
        public string nombre { get; set; }
        public decimal monto { get; set; }
        public bool estado { get; set; }
    }
}
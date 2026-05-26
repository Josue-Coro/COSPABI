namespace CapaModelo
{
    public class CM_Ruta
    {
        /*CREATE TABLE ruta
            (
             id_ruta INTEGER NOT NULL IDENTITY(1,1),
             ruta INTEGER NOT NULL,
             descripcion VARCHAR (150)
            )*/
        public int id_ruta { get; set; }
        public int ruta { get; set; }
        public string descripcion { get; set; }
    }
}
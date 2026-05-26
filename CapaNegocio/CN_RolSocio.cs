using CapaDato;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CapaModelo;
namespace CapaNegocio
{
    public class CN_RolSocio
    {
        private CD_RolSocio cdrol = new CD_RolSocio();
        public List<CM_RolSocio> Listar()
        {
            return cdrol.Listar();
        }
    }
}

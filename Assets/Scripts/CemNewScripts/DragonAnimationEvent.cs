
using UnityEngine;

public class DragonAnimationEvent : MonoBehaviour
{

    public void RangedFire(){
        GetComponentInParent<Dragon>().Fire();
    }

    public void closeFireActivate()
    {
        GetComponentInParent<Dragon>().closeAttackActivateBox();
    }

    public void closeFireDeactivate()
    {
        GetComponentInParent<Dragon>().closeAttackDeactivateBox();
    }
}

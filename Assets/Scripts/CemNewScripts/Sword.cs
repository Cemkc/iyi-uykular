using UnityEngine;

public class Sword : MonoBehaviour
{
    public Animator animator;
    public static bool DamageReady;
    private float damage;

    private void Start()
    {
        DamageReady = false;
    }

    
    private void OnTriggerEnter(Collider other)
    {
        //if (!animator.GetCurrentAnimatorStateInfo(1).IsName("H-Idle") && other.gameObject.tag == "Mobs" && !(other.gameObject.name == "col") && DamageReady)
        
        if(isMob(other))
        {
            Debug.Log(other.gameObject.name);
            damage = PlayerStats.swordDamage;
            other.gameObject.transform.GetComponentInParent<MobFeatures>().TakeDamage(damage);
        }
    }

    bool isMob(Collider other)
    {
        if(animator.GetCurrentAnimatorStateInfo(1).IsName("H-Idle")) return false;
        else if(!DamageReady) return false;
        else if(other.gameObject.tag == "Mobs") return true;
        else if(other.gameObject.name == "DragonHitBox")
        {
            other.gameObject.transform.GetComponentInParent<Dragon>().TakeDamage(damage);
        }
        else if(other.gameObject.name == "GolemCol")
        {
            other.gameObject.transform.GetComponentInParent<Golem>().Health -= 30;
        }

        return false;
    }

    public void setDamageReadyToTrue()
    {
        DamageReady = true;
        //if (animator.GetCurrentAnimatorStateInfo(1).IsName("Hit1"))
        //{
        //    damage = PlayerStats.attack1dmg;
        //}
        //else if (animator.GetCurrentAnimatorStateInfo(1).IsName("Hit2"))
        //{
        //    damage = PlayerStats.attack2dmg;
        //}
        //else if(animator.GetCurrentAnimatorStateInfo(1).IsName("Hit3"))
        //{
        //    damage = PlayerStats.attack3dmg;
        //}
    }
    public void setDamageReadyToFalse()
    {
        DamageReady = false;
    }
}

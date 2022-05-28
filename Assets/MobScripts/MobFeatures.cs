using System.Collections;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.VFX;

public class MobFeatures : MonoBehaviour
{
    Transform Player, Skin;
    NavMeshAgent Agent;
    bool AttackReady = true;
    GameObject AttackBox, col;
    Animator animator;
    Vector3 Base;
    bool once = true;
    public bool stun = false;

    public enum Mob { Archer, Gunter, Knight, Slime, Skeleton};
    public Mob mob;

    [Header ("Features")]
    [SerializeField] bool isFollowCharacter;
    [SerializeField] float BaseDistance;
    [SerializeField] float Health;
    [SerializeField] float Speed;
    [SerializeField] float Near;
    [Tooltip ("1 : Near Attack \n 2 : Project Tile Attack")][SerializeField][Range(1,2)] int AttackType;
    [SerializeField] float Attacktime;
    [SerializeField] float ReloadTime;
    [SerializeField] public float mobDamage;
    [SerializeField] GameObject _deathVFX;
    [SerializeField] Transform _vFXRootTarget;
    private AudioMaster _audioMaster;

    void Start()
    {
        Base = transform.position;
        Player = GameObject.FindGameObjectWithTag("Player").transform;
        Skin = gameObject.transform.GetChild(0).gameObject.transform;
        AttackBox = transform.GetChild(1).gameObject;
        if(AttackType == 1)AttackBox.SetActive(false);
        animator = transform.GetChild(0).gameObject.GetComponent<Animator>();
        Agent = GetComponent<NavMeshAgent>();
        Agent.speed = Speed;
        col = transform.GetChild(2).gameObject;
        _audioMaster = FindObjectOfType<AudioMaster>();
    }   
    void OnEnable()
    {
        StartCoroutine(AttackReload());
    }

    void Update()
    {
        if(Health <= 0)
        {
            animator.SetBool("Death", true);
            if(GetComponent<Collider>() != null) Destroy(GetComponent<Collider>());
            if(Agent != null) Destroy(Agent);
            if(col != null) Destroy(col);
            if(once)
            {
                once = false;
                Invoke("DeathVFX", 3.5f);
                Destroy(gameObject, 4);
            }
            return;
        }

        if(stun)
        {
            Agent.destination = transform.position;
            animator.SetBool("Stun" , true);
            return;
        }
        else animator.SetBool("Stun" , false);

        bugFix();

        if(!inBase() && !animator.GetBool("Attack"))
        {
            Agent.destination = Base;
            if(Mathf.Abs(transform.position.x - Base.x) < 0.3f && Mathf.Abs(transform.position.z - Base.z) < 0.1f) animator.SetBool("Run", false);
            else animator.SetBool("Run", true);
            return;
        }

        if(animator.GetBool("Attack"))
        {
            Vector3 rotpos = new Vector3(Player.position.x, transform.position.y, Player.position.z);
            transform.LookAt(rotpos);
        }

        if(isFollowCharacter) Walk();
        else animator.SetBool("Run", false);
    }

    //Methods
    void Walk()
    {
        if(!isNear(Near))
        {
            if(animator.GetBool("Attack")){
                Agent.destination = transform.position;
                return;
            }
            animator.SetBool("Run", true);
            Agent.destination = Player.position;
        }
        else
        {
            StartCoroutine(Attack());
            animator.SetBool("Run", false);
            Agent.destination = transform.position; 
        }
    }

    bool inBase()
    {
        float posx = Mathf.Abs(Player.position.x - transform.position.x);
        float posz = Mathf.Abs(Player.position.z - transform.position.z);

        if(posx < BaseDistance && posz < BaseDistance)
        {
            return true;
        }
        return false;
    }

    void OnTriggerEnter(Collider col)
    {
        if(col.gameObject.tag == "Attack")
        {
            
        }
        else if(col.gameObject.tag == "Attack1")
        {

        }
    }

    void bugFix()
    {
        if(!animator.GetBool("Attack") && !gameObject.name.Equals("Slime"))Skin.localRotation = Quaternion.Euler(0,0,0);
        if(animator.GetBool("Attack") && AttackType == 2) Skin.localRotation = Quaternion.Euler(0,90,0);
    }

    private void DeathVFX()
    {
        Instantiate(_deathVFX, _vFXRootTarget);;
    }

    //Enums
    IEnumerator Attack()
    {
        if(!AttackReady) yield break;
        AttackReady = false;

        if(AttackType != 2)
        {
            for(int i = 0; i < 5; i++)
            {
                if(!isNear(Near))
                {
                    AttackReady = true;
                    yield break;
                }
                //Debug.Log(i);

                yield return new WaitForSecondsRealtime(Attacktime * 0.1f);
            }
        }
        else yield return new WaitForSecondsRealtime(Attacktime);

        if(AttackType == 1) //Near
        {
            animator.SetBool("Attack", true);
            yield return new WaitForSeconds(0.8f);
            AttackBox.SetActive(true);
            yield return new WaitForSeconds(0.8f);
            AttackBox.SetActive(false);
            yield return new WaitForSeconds(0.8f);
            animator.SetBool("Attack", false);
        }
        else if(AttackType == 2) //Projectile
        {
            animator.SetBool("Attack", true);
            yield return new WaitForSeconds(0.2f);
            //Debug.Log("ok atıldı");
            //_audioMaster.PlaySound(9, transform.position, 1);
            AttackBox.transform.GetChild(0).gameObject.SetActive(true);
            yield return new WaitForSeconds(0.4f);
            animator.SetBool("Attack", false);
        }

        StartCoroutine(AttackReload());
    }
    IEnumerator AttackReload()
    {
        yield return new WaitForSecondsRealtime(ReloadTime);
        AttackReady = true;
    }

    public IEnumerator StunDuration(float time)
    {
        if(stun) yield break;
        // _audioMaster.PlaySound(0, transform.position, 1);
        stun = true;
        yield return new WaitForSecondsRealtime(time);
        stun = false;
    }


    //bools
    bool isNear(float neer)
    {
        float posx = Mathf.Abs(Player.position.x - transform.position.x);
        float posz = Mathf.Abs(Player.position.z - transform.position.z);

        if(posx > neer || posz > neer) return false;
        else return true;
    }

    public void TakeDamage(float damage)
    {
        Health -= damage;
        int x = Random.Range(0, 2);
        // Debug.Log(this.transform.name + "Took " + damage + " damage");

        // switch (mob)
        // {
        //     case Mob.Gunter :
        //         _audioMaster.PlaySound(3, transform.position, 1);
        //         break;
        //     case Mob.Archer :
        //         if (x == 1)
        //         {
        //             _audioMaster.PlaySound(4, transform.position, 1);
        //         }
        //         else
        //         {
        //             _audioMaster.PlaySound(5, transform.position, 1);
        //         }
        //         break;
        //     case Mob.Knight :
        //         if (x == 1)
        //         {
        //             _audioMaster.PlaySound(4, transform.position, 1);
        //         }
        //         else
        //         {
        //             _audioMaster.PlaySound(5, transform.position, 1);
        //         }
        //         break;
        //     case Mob.Slime :
        //         _audioMaster.PlaySound(7, transform.position, 1);
        //         break;
        // }

    }
}

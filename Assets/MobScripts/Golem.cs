using System.Collections;
using UnityEngine;
using UnityEngine.AI;

public class Golem : MonoBehaviour
{
    NavMeshAgent NM;
    Transform player;
    public Animator anim;
    bool AttackReady = true, LongAttackReady = false;
    bool once = true;
    Collider col;

    float firstjumptime;

    [Header ("Preferences")]
    [SerializeField] public float Health = 180;
    [SerializeField] float Speed = 2.5f;
    [SerializeField] GameObject Attackbox;
    [SerializeField] GameObject LongAttackBox;
    [SerializeField] float AttackReadyTime = 4;
    [SerializeField] float LongAttackReadyTime = 20;
    [SerializeField] float LongAttackDistance = 8;
    [SerializeField] GameObject _deathVFX;
    [SerializeField] Transform _vFXRootTarget;
    public GameObject AttackTarget;
    
    void Start()
    {
        firstjumptime = Random.Range(1f,8f);
        StartCoroutine(LongReady());
        NM = transform.parent.gameObject.GetComponent<NavMeshAgent>();
        player = GameObject.FindGameObjectWithTag("Player").gameObject.transform;
        NM.speed = Speed;
        Attackbox.SetActive(false);
        LongAttackBox.SetActive(false);
        col = gameObject.transform.parent.GetComponent<Collider>();
    }
    public void Walk()
    {
        if(!islife()) return;
        NM.speed = Speed;
        NM.isStopped = false;
    }

    public void NotWalk()
    {
        NM.isStopped = true;
    }

    public void Attack()
    {
        if(!islife()) return;
        NM.isStopped = true;
        Attackbox.SetActive(true);
    }
    public void AttackClose()
    {
        if(!islife()) return;
        Attackbox.SetActive(false);
        LongAttackBox.SetActive(false);
        anim.SetBool("AttackHit", false);
        anim.SetBool("AttackJump", false);
        AttackTarget.SetActive(false);
    }

    public void AttackJumpBlackHole()
    {
        AttackTarget.transform.position = player.position;
        AttackTarget.SetActive(true);
    }

    public void AttackJumpTeleport()
    {
        NM.nextPosition = AttackTarget.transform.position;
    }
    public void LongAttack()
    {
        LongAttackBox.SetActive(true);
    }

    void Update()
    {
        if(!islife())
        {
            //dead true;
            NM.isStopped = true;
            anim.SetBool("Death", true);
            if(col != null) Destroy(col);

            if(once)
            {
                once = false;
                Invoke("DeathVFX", 3.5f);
                Destroy(gameObject, 4);
            }
            return;
        }
        if(anim.GetBool("AttackJump") || anim.GetBool("AttackHit"))
        {
            NM.isStopped = true;
            return;
        }

        NM.destination = player.position;

        transform.localPosition = new Vector3(0,0,0);

        if(isFarth(LongAttackDistance) && LongAttackReady)
        {
            StartCoroutine(LongReady());
            anim.SetBool("AttackJump" , true);
        }
        else if(isFarth(2f)) anim.SetBool("Walk", true);
        else
        {
            NM.isStopped = true;
            anim.SetBool("Walk", false);
        }

        if(isNear(2.5f) && AttackReady)
        {
            transform.parent.transform.LookAt (new Vector3(player.position.x, transform.parent.transform.position.y, player.transform.position.z)); 
            StartCoroutine(Reload());
            anim.SetBool("AttackHit", true);
        }
    }

    bool isNear(float neer)
    {
        float posx = Mathf.Abs(player.position.x - transform.position.x);
        float posz = Mathf.Abs(player.position.z - transform.position.z);

        if(posx > neer || posz > neer) return false;
        else return true;
    }

    bool isFarth(float Far)
    {
        float posx = Mathf.Abs(player.position.x - transform.position.x);
        float posz = Mathf.Abs(player.position.z - transform.position.z);

        if(posx < Far && posz < Far)
        {
            return false;
        }
        return true;
    }

    private void DeathVFX()
    {
        Instantiate(_deathVFX, _vFXRootTarget);
    }

    IEnumerator Reload()
    {
        AttackReady = false;
        yield return new WaitForSeconds(AttackReadyTime);
        AttackReady = true;
    }
    IEnumerator LongReady()
    {
        LongAttackReady = false;
        yield return new WaitForSeconds(LongAttackReadyTime + firstjumptime);
        LongAttackReady = true;
    }

    //bool 
    bool islife()
    {
        if(Health <= 0)return false;
        else return true;
    }
}

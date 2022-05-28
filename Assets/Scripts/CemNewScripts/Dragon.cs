using UnityEngine;
using UnityEngine.AI;
using System.Collections;

public class Dragon : MonoBehaviour
{
    NavMeshAgent agent;
    public GameObject player;
    public Animator animator;
    public GameObject FireBall;
    public GameObject DeathVFX;
    [SerializeField] private Transform parent;
    float distanceToPlayer;
    float outOfAttackDistance;
    bool hasDied;
    Vector3 originPos;

    [SerializeField] float Health;
    [SerializeField] float followingDistance;
    [SerializeField] float attackDistance;
    [SerializeField] float FireReloadTime;
    [SerializeField] float RangedAttackDistance;
    [SerializeField] float backToOrigin;
    public float closeAttackDamage = 30f;
    [SerializeField] float closeAttackCooldown;

    public enum DragonState { Idle, Triggered, Attack, RangedAttack, backToOrigin, Dying }
    public DragonState dragonState;

    void Start()
    {
        agent = GetComponent<NavMeshAgent>();
        originPos = transform.position;
    }

    void Update()
    {
        distanceToPlayer = Vector3.Distance(transform.position, player.transform.position);

        if (hasDied)
        {
            dragonState = DragonState.Dying;
        }
        
        switch (dragonState)
        {
            case DragonState.Idle:
                IdleMov();
                break;
            case DragonState.Triggered:
                triggeredMovement();
                break;
            case DragonState.Attack:
                AttackMovement();
                break;
            case DragonState.RangedAttack:
                RangedAttackMovement();
                break;
            case DragonState.backToOrigin:
                backToOriginMovement();
                break;
            case DragonState.Dying:
                kill();
                break;
        }
    }

    private void kill()
    {
        animator.SetTrigger("Die");
        agent.isStopped = true;
        StartCoroutine(dieAfterSeconds());
    }

    private void IdleMov()
    {
        agent.isStopped = true;
        animator.SetTrigger("Idle");
        if(distanceToPlayer < followingDistance)
        {
            agent.isStopped = false;
            dragonState = DragonState.Triggered;
        }
    }

    private void triggeredMovement()
    {
        agent.isStopped = false;
        animator.SetTrigger("Idle");
        agent.destination = player.transform.position;
        if (distanceToPlayer < RangedAttackDistance )
        {
            if (distanceToPlayer < attackDistance)
            {
                dragonState = DragonState.Attack;
            }
            else
            {
                dragonState = DragonState.RangedAttack;
            }
        }
        if(distanceToPlayer > backToOrigin)
        {
            dragonState = DragonState.backToOrigin;
        }
    }

    private void AttackMovement()
    {
        agent.isStopped = true;
        animator.SetTrigger("Attack");
        Vector3 lookAtPlayer = new Vector3(player.transform.position.x, transform.position.y, player.transform.position.z);
        transform.LookAt(lookAtPlayer);
        //animator.SetTrigger("Attack");
        //if (isCloseAttackReady)
        //{
        //    isCloseAttackReady = false;
        //    transform.GetChild(1).gameObject.SetActive(true);
        //    StartCoroutine(startCloseAttackCooldownCountown());
        //}
        if (distanceToPlayer > attackDistance)
        {
            dragonState = DragonState.RangedAttack;
        }
    }

    private void RangedAttackMovement()
    {
        animator.SetTrigger("Ranged");
        agent.isStopped = true;
        Vector3 lookAtPlayer = new Vector3(player.transform.position.x, transform.position.y, player.transform.position.z);
        transform.LookAt(lookAtPlayer);
        //if (isFireReady)
        //{
        //    isFireReady = false;
        //    Fire();
        //    StartCoroutine(FireCoolDown());
        //}
        if(distanceToPlayer < attackDistance)
        {
            dragonState = DragonState.Attack;
        }
        if(distanceToPlayer > RangedAttackDistance)
        {
            dragonState = DragonState.Triggered;
        }
    }

    private void backToOriginMovement()
    {
        animator.SetTrigger("Idle");
        agent.destination = originPos;
        if (agent.isStopped)
        {
            dragonState = DragonState.Idle;
        }
    }

    public void Fire()
    {
        Debug.Log(transform.GetChild(2).name);
        Instantiate(FireBall, transform.GetChild(2).position, transform.GetChild(2).rotation);
    }

    public void closeAttackActivateBox()
    {

        transform.GetChild(1).gameObject.SetActive(true);
    }

    public void closeAttackDeactivateBox()
    {

        transform.GetChild(1).gameObject.SetActive(false);
    }

    public void TakeDamage(float damage)
    {
        Health -= damage;
        Debug.Log(Health);
        if(Health <= 0)
        {
            hasDied = true;
        } 
    }

    IEnumerator dieAfterSeconds()
    {
        yield return new WaitForSeconds(2f);
        GameObject obj = Instantiate(DeathVFX, transform.position, Quaternion.identity, parent);
        Destroy(gameObject);
    }

    //IEnumerator FireCoolDown()
    //{
    //    yield return new WaitForSeconds(FireReloadTime);
    //    isFireReady = true;
    //}

    //IEnumerator startCloseAttackCooldownCountown()
    //{
    //    yield return new WaitForSeconds(closeAttackCooldown);
    //    isCloseAttackReady = true;
    //}
}

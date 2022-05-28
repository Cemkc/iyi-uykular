using System.Collections;
using UnityEngine.Events;
using UnityEngine;

[System.Serializable]
public class SkillEvent : UnityEvent<string>
{
}

public class PlayerSkills : MonoBehaviour
{
    [Header("Teleport:")] 
    [SerializeField] private float tpRange;
    [SerializeField] private float tpOffset;
    [SerializeField] private float tpCooldown;

    [Header("Stun")]
    [SerializeField] private float stunCooldown;
    [SerializeField] private float stunDuration;

    [Header("AOEproperties")]
    [SerializeField] private float AOESkillDamage;
    [SerializeField] private float AOESkillRange;
    [SerializeField] private float AOESkillCooldown;

    [Header("VFX Prefabs")]
    [SerializeField] private Transform parent;
    [SerializeField] private GameObject teleportVFX;
    [SerializeField] private GameObject stunVFX;
    [SerializeField] private GameObject AoeVfx;

    public bool canTp = false;
    public bool canStun = false;
    public bool canAoE = false;


    public SkillEvent skillEvent;
    //LayerMask mask;

    //private void Start()
    //{

    //    LayerMask mask = LayerMask.GetMask("Mobs");
    //}

    private bool isTpReady;
    private bool isStunReady;
    private bool isAoeReady;

    private void Start()
    {
        isTpReady = true;
        isStunReady = true;
        isAoeReady = true;
    }

    private void FixedUpdate()
    {
        RaycastHit hit;
        if(InputMaster.tpInput && isTpReady && canTp)
        {
            Debug.Log("Input is taken and cooldown is ready");
            LayerMask mask = LayerMask.GetMask("Mobs");
            if (Physics.Raycast(transform.position + Vector3.up, transform.forward, out hit, tpRange, mask))
            {
                Effect_Teleport();
                Debug.Log("Target acquired");
                Vector3 tpPosition = new Vector3(hit.transform.parent.position.x, transform.position.y, hit.transform.parent.position.z);
                transform.position = tpPosition - hit.transform.TransformDirection(Vector3.forward) * tpOffset;
                isTpReady = false;
                StartCoroutine(CooldownCoroutine(tpCooldown, "teleport"));
                GameManager.instance.currentSkillState = GameManager.PlayerSkillState.Teleport;
                skillEvent.Invoke("teleport");
                
                
            }
        }

        if (InputMaster.stunInput && isStunReady && canStun)
        {
            LayerMask mask = LayerMask.GetMask("Mobs");
            if (Physics.Raycast(transform.position + Vector3.up, transform.forward, out hit, tpRange, mask))
            {
                if(hit.transform.name != "DragonHitBox"){    
                    Effect_Stun(hit.transform);
                    isStunReady = false;
                    StartCoroutine(hit.transform.GetComponentInParent<MobFeatures>().StunDuration(stunDuration));
                    StartCoroutine(CooldownCoroutine(stunCooldown, "stun"));
                    skillEvent.Invoke("stun");
                }

            }
        }

        //if (InputMaster.stunInput && isStunReady && !(hit.collider.name == "GolemCol" || hit.collider.name == "GolemCol"))
        //{
        //    Effect_Stun(hit.transform);
        //    isStunReady = false;
        //    StartCoroutine(hit.transform.parent.GetComponent<MobFeatures>().StunDuration(stunDuration));
        //    StartCoroutine(CooldownCoroutine(stunCooldown, "stun"));
        //    skillEvent.Invoke("stun");
        //}

        if (InputMaster.AOEattackInput && isAoeReady && canAoE)
        {
            InputMaster.AOEattackInput = false;
            isAoeReady = false;
            Effect_AOEattack();
            StartCoroutine(AOEattack());
            StartCoroutine(CooldownCoroutine(AOESkillCooldown, "aoe"));
        }

    }

    IEnumerator AOEattack()
    {
        yield return new WaitForSeconds(0.25f);
        Collider[] colliders = Physics.OverlapSphere(transform.position, AOESkillRange);
        foreach (Collider c in colliders)
        {
            if (c.GetComponent<MobFeatures>())
            {
                c.GetComponent<MobFeatures>().TakeDamage(AOESkillDamage);
            }
        }

    }

    IEnumerator CooldownCoroutine(float duration, string skill)
    {
        yield return new WaitForSeconds(duration);
        if (skill == "teleport")
        {
            isTpReady = true;
        }else if (skill == "stun")
        {
            isStunReady = true;
        }else if(skill == "aoe")
        {
            isAoeReady = true;
        }
    }

    private void Effect_Teleport()
    {
        Vector3 vfxRotation = new Vector3();
        vfxRotation.x = -90f * Mathf.Deg2Rad;
        vfxRotation.y = transform.rotation.eulerAngles.y * Mathf.Deg2Rad;

        teleportVFX.GetComponentInChildren<ParticleSystem>().startRotation3D = vfxRotation;
        GameObject obj = Instantiate(teleportVFX, transform.position, Quaternion.identity, parent);
    }

    private void Effect_Stun(Transform target)
    {
        GameObject obj = Instantiate(stunVFX, target.position, Quaternion.identity, parent);
    }

    private void Effect_AOEattack()
    {
        GameObject obj = Instantiate(AoeVfx, transform.position, Quaternion.identity, parent);
    }

    public void SetBool(int index)
    {
        switch (index)
        {
            case 0:
                canTp = true;
                break;
            case 1:
                canStun = true;
                break;
            case 2:
                canAoE = true;
                break;
        }
    }
}

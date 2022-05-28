using UnityEngine;

public class PlayerAnimator : MonoBehaviour
{
    public CharacterController characterController;
    public Animator animator;
    int velocityXHash;
    int velocityZHash;
    float forwardVelocity;
    float rightVelocity;

    float comboTimer;
    [SerializeField] float comboDuration;

    private enum AnimState { Neutral, hitOne,hitTwo, hitThree };
    [SerializeField] AnimState animState;

    [SerializeField] bool swordEquipped;
    [SerializeField] bool bowEquipped;

    public Rigidbody projectile;

    private void Start()
    {
        velocityXHash = Animator.StringToHash("VelocityX");
        velocityZHash = Animator.StringToHash("VelocityZ");
        animState = AnimState.Neutral;
    }

    private void Update()
    {
        forwardVelocity = Vector3.Dot(characterController.velocity, transform.forward);
        rightVelocity = Vector3.Dot(characterController.velocity, transform.right);

        animator.SetFloat(velocityXHash, rightVelocity);
        animator.SetFloat(velocityZHash, forwardVelocity);

        if (swordEquipped)
        {
            if (InputMaster.attackIput && animState == AnimState.Neutral)
            {
                InputMaster.attackIput = false;
                comboTimer = Time.time;
                animator.SetTrigger("hit1");
                animState = AnimState.hitOne;
            }

            switch (animState)
            {
                case AnimState.hitOne:
                    if (Time.time - comboTimer > comboDuration)
                    {
                        animator.SetTrigger("backToBlend");
                        animState = AnimState.Neutral;
                    }
                    else if (InputMaster.attackIput)
                    {
                        comboTimer = Time.time;
                        InputMaster.attackIput = false;
                        animator.SetTrigger("hit2");
                        animState = AnimState.hitTwo;

                    }
                    break;
                case AnimState.hitTwo:
                    if (Time.time - comboTimer > comboDuration)
                    {
                        animator.SetTrigger("backToBlend");
                        animState = AnimState.Neutral;
                    }
                    else if (InputMaster.attackIput)
                    {
                        InputMaster.attackIput = false;
                        comboTimer = Time.time;
                        animator.SetTrigger("hit3");
                        animState = AnimState.hitThree;

                    }
                    break;
                case AnimState.hitThree:
                    if (animator.GetCurrentAnimatorStateInfo(1).IsName("Hit3"))
                    {
                        InputMaster.attackIput = false;
                        animator.SetTrigger("backToBlend");
                        animState = AnimState.Neutral;
                    }
                    break;

                default:
                    break;
            }
        }
        else
        {
            if (InputMaster.aimInput)
            {
                animator.SetBool("isAiming", true);

                if (InputMaster.attackIput)
                {
                    InputMaster.attackIput = false;
                    
                    Rigidbody clone;
                    Vector3 spawnPos = new Vector3(transform.position.x, transform.position.y + 2f + transform.position.z);
                    clone = Instantiate(projectile, spawnPos, transform.rotation);

                    // Give the cloned object an initial velocity along the current
                    // object's Z axis
                    clone.velocity = transform.TransformDirection(Vector3.forward * 10);
                }
            }
            else
            {
                animator.SetBool("isAiming", false);
            }

            

        }

        //AnimatorTransitionInfo ati = animator.GetAnimatorTransitionInfo(1);

        //if (ati.IsName("Hit1 -> Hit2") || ati.IsName("Hit1 -> Hit2") || ati.IsName("Hit2 -> Hit3") || animator.GetCurrentAnimatorStateInfo(1).IsName("H-Idle"))
        //{
        //    Sword.DamageReady = true;
        //    //Debug.Log("Transition");
        //}

    }
}

using System;
using UnityEngine;

public class Player : MonoBehaviour
{

    private CharacterController charCont;
    //public Transform CameraTransform;
    [SerializeField] Vector3 _mouseInput;
    [SerializeField] LayerMask layerMask;
    [SerializeField] Vector3 normal;
    [SerializeField] float angle;
    [SerializeField] public Vector3 movingDirection;

    [Header("Values")]
    [SerializeField] private float walkingSpeed = 12f;
    [SerializeField] private float runningSpeed = 18f;
    [SerializeField] private float dashSpeed = 25f;
    [SerializeField] private float gravity = -9.81f;
    [SerializeField] private float standingHeight = 4.3f;
    [SerializeField] private float dashDuration = 0.15f;
    [SerializeField] bool isGrounded;

    public RaycastHit raycastHit;

    private float rollStartTime;
    private bool firstLoop;
    private float speed;
    private string skillEvent;
    private Orbit orbit;
    
    private AudioMaster audioMaster;

    void Start()
    {
        orbit = GameObject.Find("Camera").transform.GetComponent<Orbit>();
        charCont = GetComponent<CharacterController>();
        GameManager.instance.setPlayerState(GameManager.PlayerStates.Idle);
        movingDirection = Vector3.zero;
        firstLoop = true;
        audioMaster = FindObjectOfType<AudioMaster>();
    }


    private void Update()
    {
        this.isGrounded = charCont.isGrounded;

        if (InputMaster.startGameInput)
        {
            Debug.Log("GameStarted");
        }

        switch (GameManager.instance.getPlayerState())
        {
            case GameManager.PlayerStates.Idle:
                IdleStateMovement();
                break;
            case GameManager.PlayerStates.Walking:
                WalkingStateMovement();
                break;
            case GameManager.PlayerStates.Running:
                RunningStateMovement();
                break;
            case GameManager.PlayerStates.Dashing:
                dashStateMovement();
                break;
            case GameManager.PlayerStates.Dying:
                DyingStateMovement();
                break;
        }
        
        Debug.Log("orbit._cameraForward +  + orbit._cameraRight");


        movingDirection.y += gravity * Time.deltaTime;


    }

    private void DyingStateMovement()
    {
        
    }

    private void OnDrawGizmos()
    {
        Gizmos.DrawSphere(_mouseInput, 0.5f);
    }

    private void IdleStateMovement()
    {
        if (InputMaster.moveInput.magnitude >= 0.1f)
        {
            if (InputMaster.runInput)
            {
                GameManager.instance.currentPlayerState = GameManager.PlayerStates.Running;
            }
            else
            {
                GameManager.instance.currentPlayerState = GameManager.PlayerStates.Walking;
            }
        }

        lookAtCursor();
    }

    private void WalkingStateMovement()
    {
        if (InputMaster.moveInput.magnitude >= 0.1f)
        {
            if (InputMaster.runInput)
            {
                speed = runningSpeed;
                GameManager.instance.setPlayerState(GameManager.PlayerStates.Running);
            }
            else if (InputMaster.rollInput)
            {
                GameManager.instance.currentPlayerState = GameManager.PlayerStates.Dashing;
            }
            else
            {
                speed = walkingSpeed;
            }
        }
        else
        {
            GameManager.instance.currentPlayerState = GameManager.PlayerStates.Idle;
        }

        //movingDirection.x = InputMaster.moveInput.x;
        //movingDirection.z = InputMaster.moveInput.y;

        movingDirection = (orbit._cameraRight * -InputMaster.moveInput.x) + (orbit._cameraForward * InputMaster.moveInput.y);

        movingDirection.y = -2f;

        charCont.Move(movingDirection * speed * Time.deltaTime);

        lookAtCursor();
    }

    private void RunningStateMovement()
    {
        if (InputMaster.moveInput.magnitude >= 0.1f)
        {
            if (InputMaster.runInput)
            {
                speed = runningSpeed;
                
                if(InputMaster.rollInput)
                {
                    GameManager.instance.currentPlayerState = GameManager.PlayerStates.Dashing;
                }
            }
            else
            {
                speed = walkingSpeed;
                GameManager.instance.currentPlayerState = GameManager.PlayerStates.Walking;
            }
        }
        else
        {
            GameManager.instance.currentPlayerState = GameManager.PlayerStates.Idle;
        }

        movingDirection = (orbit._cameraRight * -InputMaster.moveInput.x) + (orbit._cameraForward * InputMaster.moveInput.y);

        movingDirection.y = -2f;

        charCont.Move(movingDirection * speed * Time.deltaTime);
        

        lookAtCursor();
    }

    private void dashStateMovement()
    {
        InputMaster.rollInput = false;
        if (firstLoop)
        {
            rollStartTime = Time.time;
            movingDirection.x = movingDirection.x * dashSpeed / speed;
            movingDirection.z = movingDirection.z * dashSpeed / speed;
            
            // audioMaster.PlaySound(2, transform.position, 1);
            
            firstLoop = false;
        }
        charCont.Move(movingDirection * Time.deltaTime);
        if (Time.time - rollStartTime > 0.15f)
        {
            GameManager.instance.currentPlayerState = GameManager.PlayerStates.Idle;
            firstLoop = true;
        }
    }

    void lookAtCursor()
    {
        Ray ray = Camera.main.ScreenPointToRay(InputMaster.mouseAxis);

        Physics.Raycast(ray, out raycastHit, Mathf.Infinity, layerMask);
        _mouseInput = raycastHit.point;

        normal = (raycastHit.point - transform.position).normalized;
        angle = Mathf.Atan2(normal.x, normal.z) * Mathf.Rad2Deg;

        //Prevents sudden rotation when mouse goes out off border.
        if (_mouseInput != Vector3.zero)
            transform.rotation = Quaternion.Euler(0, angle, 0);
    }

    public void onSkillEvent(string skillEvent)
    {
        Debug.Log(skillEvent + " has been used ");
        this.skillEvent = skillEvent;
    }

}

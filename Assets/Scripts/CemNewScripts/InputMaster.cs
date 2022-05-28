using UnityEngine;
using UnityEngine.Events;


public class InputMaster : MonoBehaviour
{
    Controls control;
    public static Vector2 moveInput;
    public static bool rollInput;
    public static bool runInput;
    public static float cameraAxisInput;
    public static Vector2 mouseAxis;
    public static bool shootInput;
    public static bool interactInput;
    public static bool tpInput;
    public static bool stunInput;
    public static bool attackIput;
    public static bool aimInput;
    public static bool AOEattackInput;
    public static bool startGameInput;

    private void Awake()
    {
        control = new Controls();

        control.PlayerMov.Walk.performed += ctx => Move(ctx.ReadValue<Vector2>());
        control.PlayerMov.Walk.canceled += ctx => Move(ctx.ReadValue<Vector2>());

        //control.PlayerMov.Jump.performed += ctx => Jump(ctx.performed);
        //control.PlayerMov.Jump.canceled += ctx => Jump(ctx.performed);

        control.PlayerMov.Look.performed += ctx => Axes(ctx.ReadValue<Vector2>());
        control.PlayerMov.Look.canceled += ctx => Axes(ctx.ReadValue<Vector2>());

        control.PlayerMov.Roll.performed += ctx => Roll(ctx.performed);
        control.PlayerMov.Roll.canceled += ctx => Roll(ctx.performed);

        control.PlayerMov.Aim.performed += ctx => Aim(ctx.performed);
        control.PlayerMov.Aim.canceled += ctx => Aim(ctx.performed);

        control.PlayerMov.Run.performed += ctx => Run(ctx.performed);
        control.PlayerMov.Run.canceled += ctx => Run(ctx.performed);

        control.PlayerMov.AOEattack.performed += ctx => AOEattack(ctx.performed);
        control.PlayerMov.AOEattack.canceled += ctx => AOEattack(ctx.performed);

        control.PlayerMov.TeleportAttribute.performed += ctx => TelePort(ctx.performed);
        control.PlayerMov.TeleportAttribute.canceled += ctx => TelePort(ctx.performed);

        control.PlayerMov.Attack.performed += ctx => Attack(ctx.performed);
        control.PlayerMov.Attack.canceled += ctx => Attack(ctx.performed);

        control.PlayerMov.StunAttribute.performed += ctx => Stun(ctx.performed);
        control.PlayerMov.StunAttribute.canceled += ctx => Stun(ctx.performed);

        control.PlayerMov.StartGame.performed += ctx => StartGame(ctx.performed);
        control.PlayerMov.StartGame.canceled += ctx => StartGame(ctx.performed);

        control.PlayerMov.CameraRotation.performed += ctx => CameraInput(ctx.ReadValue<float>());
        control.PlayerMov.CameraRotation.canceled += ctx => CameraInput(ctx.ReadValue<float>());
    }

    private void StartGame(bool performed)
    {
        startGameInput = performed;
    }

    private void AOEattack(bool performed)
    {
        AOEattackInput = performed;
    }

    private void Aim(bool performed)
    {
        aimInput = performed;
    }

    private void Attack(bool performed)
    {
        attackIput = performed;
    }

    private void Stun(bool performed)
    {
        stunInput = performed;
    }

    private void TelePort(bool performed)
    {
        tpInput = performed;
    }

    private void Move(Vector2 movDirection)
    {
        moveInput = movDirection;
    }

    private void Run(bool isRunPerformed)
    {
        runInput = isRunPerformed;
    }

    private void CameraInput(float performed)
    {
        cameraAxisInput = performed;
    }

    private void Axes(Vector2 mouseAxes)
    {
        mouseAxis = mouseAxes;
    }

    private void Roll(bool isRollPressed)
    {
        rollInput = isRollPressed;
    }

    private void Shoot(bool isShootPerformed)
    {
        shootInput = isShootPerformed;
    }

    private void OnEnable()
    {
        control.Enable();
        
    }
    private void OnDisable()
    {
        control.Disable();
    }
   
}

using UnityEngine;

public class GameManager : MonoBehaviour
{
    #region singleton

    public static GameManager instance;

    private void Awake()
    {
        if (instance != null)
        {
            Debug.LogError("More Than One Character State!");
            return;
        }
        instance = this;
    }
    #endregion

    public struct playerInventory
    {
        bool bow;
        bool sword;
    };


    public enum PlayerStates{ Idle, Walking, Dashing, Running, Dying };
    public PlayerStates currentPlayerState;
    public enum PlayerSkillState { Neutral, Teleport };
    public PlayerSkillState currentSkillState;

    public void setPlayerState(PlayerStates playerStates)
    {
        currentPlayerState = playerStates;
    }
    public PlayerStates getPlayerState()
    {
        return currentPlayerState;
    }

}

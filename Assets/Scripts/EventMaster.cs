using UnityEngine;

public class EventMaster : MonoBehaviour
{
    [SerializeField] private PlayerSkills playerSkills;
    [SerializeField] private DialogueMaster dialogueMaster;
    [SerializeField] private ChoicesMaster choiceMaster;

    public void StopTime()
    {
        Time.timeScale = 0;
    }

    public void StartTime()
    {
        Time.timeScale = 1;
    }

    public void CheckSkill()
    { 
       if (playerSkills.canTp == true)
       {
            dialogueMaster.PlaySegment(8);
       }
       else if (playerSkills.canStun == true)
       {
            dialogueMaster.PlaySegment(10);
        }
       else if (playerSkills.canAoE == true)
       {
            dialogueMaster.PlaySegment(11);
        }
    }

    public void CheckSkill2()
    {
        if (playerSkills.canTp == true)
        {
            choiceMaster.LoadChoice(2);
        }
        else if (playerSkills.canStun == true)
        {
            choiceMaster.LoadChoice(4);
        }
        else if (playerSkills.canAoE == true)
        {
            choiceMaster.LoadChoice(5);
        }
    }
}

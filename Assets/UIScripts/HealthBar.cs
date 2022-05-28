using UnityEngine;
using UnityEngine.UI;

public class HealthBar : MonoBehaviour
{
    float Health;
    PlayerStats PS;
    Slider slider;
    void Start()
    {
        PS = GameObject.FindGameObjectWithTag("Player").gameObject.GetComponent<PlayerStats>();
        slider = GetComponent<Slider>();
        slider.value = PS.playerHealth;
        Health = PS.playerHealth;
    }
    void Update()
    {
        if(Mathf.Abs(PS.playerHealth - Health) > 0.5f)
        {
            if(PS.playerHealth < Health) Health -= 0.5f;
            else if(PS.playerHealth  > Health) Health += 0.5f;
        }

        slider.value = Health;
    }
}

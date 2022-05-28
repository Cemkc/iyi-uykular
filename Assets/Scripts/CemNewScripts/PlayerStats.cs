using UnityEngine;
using UnityEngine.SceneManagement;

public class PlayerStats : MonoBehaviour
{
    public GameObject player;
    [SerializeField] public float playerHealth;
    [SerializeField] private float playerHealtRegenTime;
    [SerializeField] private float playerHealtRegenRate;
    [SerializeField] private bool Invincible;
    public static float swordDamage;
    private float timer;

    private void Start()
    {
        timer = Time.time;
        swordDamage = 20;
    }

    private void Update()
    {
        if(Time.time - timer > playerHealtRegenTime)
        {
            if(playerHealth < 100)
            {
                playerHealth += playerHealtRegenRate * Time.deltaTime;
            }
            else
            {
                playerHealth = 100;
            }
        }
    }

    public void TakeDamage(float damage)
    {
        playerHealth -= damage;
        
        //Debug.Log("Taken " + damage + " Damage");
        if(playerHealth <= 0 && !Invincible)
        {
            //Debug.Log("You Died!");
            int scene = SceneManager.GetActiveScene().buildIndex;
            SceneManager.LoadScene(scene);  
        }
        timer = Time.time;
    }
}

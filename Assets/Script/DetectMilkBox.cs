using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DetectMilkBox : MonoBehaviour
{
    // Start is called before the first frame update
    public GameObject effect; 
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnTriggerStay(Collider other)
    {
        if (other.CompareTag("MilkBox"))
        {
            int i = other.GetComponent<MilkBoxSettings>().playerOrder;
            if (i == 0)
            {
                PlayerIndentify.scoreNum0++;
                SoundsManager.PlayDeliverMilkBoxAudio();
                Instantiate(effect, other.transform.position, Quaternion.identity);
                Destroy(other.gameObject);
            }
            if (i == 1)
            {
                PlayerIndentify.scoreNum1++;
                SoundsManager.PlayDeliverMilkBoxAudio();
                Instantiate(effect, other.transform.position, Quaternion.identity);
                Destroy(other.gameObject);
            }
            if (i == 2)
            {
                PlayerIndentify.scoreNum2++;
                SoundsManager.PlayDeliverMilkBoxAudio();
                Instantiate(effect, other.transform.position, Quaternion.identity);
                Destroy(other.gameObject);
            }
            if (i == 3)
            {
                PlayerIndentify.scoreNum3++;
                SoundsManager.PlayDeliverMilkBoxAudio();
                Instantiate(effect, other.transform.position, Quaternion.identity);
                Destroy(other.gameObject);
                
            }
        }
    }

    IEnumerator Wait2DestoryMilkBox(GameObject other)
    {
        yield return new WaitForSeconds(0.3f);
        int i = other.GetComponent<MilkBoxSettings>().playerOrder;
        if (i == 0)
        {
            PlayerIndentify.scoreNum0++;

            Destroy(other);
        }
        if (i == 1)
        {
            PlayerIndentify.scoreNum1++;
            Destroy(other);
        }
        if (i == 2)
        {
            PlayerIndentify.scoreNum2++;
            Destroy(other);
        }
        if (i == 3)
        {
            PlayerIndentify.scoreNum3++;
            Destroy(other);
        }
        
        
    }
}

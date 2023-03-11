using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerDetectToPlay : MonoBehaviour
{
    // Start is called before the first frame update
    public GameObject stateImage;
    
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Player")
        {
            stateImage.SetActive(true);
            PlayerIndentify.pNum += 1;
        }
    }
}

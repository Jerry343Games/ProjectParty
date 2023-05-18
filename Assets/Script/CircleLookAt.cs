using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CircleLookAt : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        transform.LookAt(new Vector3(transform.position.x,transform.position.y,transform.position.z+10), Vector3.up);
    }
}
